// --- STATE & STORAGE ---
const Store = {
    get: (key, fallback) => JSON.parse(localStorage.getItem('gameforge_' + key)) || fallback,
    set: (key, val) => localStorage.setItem('gameforge_' + key, JSON.stringify(val)),
    clear: () => localStorage.clear()
};

let state = {
    users: Store.get('users', [
        { username: 'admin', password: 'atss19', dept: 'YÖNETİM', role: 'admin', lastSeen: Date.now(), updatedAt: Date.now() }
    ]).filter(u => !['Mehmet_Dev', 'Ayşe_Art', 'Can_Sound'].includes(u.username)),
    tasks: Store.get('tasks', [
        { id: 1, title: "Ana karakter hareket mekaniği", dept: "YAZILIM", status: "AKTİF", progress: "%80", done: false, critical: true, assignee: 'admin', updatedAt: Date.now() },
        { id: 2, title: "Bölüm 1 harita tasarımı", dept: "TASARIM", status: "AKTİF", progress: "%40", done: false, critical: true, assignee: 'admin', updatedAt: Date.now() }
    ]),
    pendingActions: Store.get('pendingActions', []),
    activityLog: Store.get('activityLog', []),
    currentUser: Store.get('currentUser', null)
};

const saveState = () => {
    // Before saving, ensure currentUser's lastSeen is up to date in the users array
    if(state.currentUser) {
        state.currentUser.lastSeen = Date.now();
        const userIdx = state.users.findIndex(u => u.username === state.currentUser.username);
        if(userIdx > -1) state.users[userIdx].lastSeen = state.currentUser.lastSeen;
    }
    Store.set('users', state.users);
    Store.set('tasks', state.tasks);
    Store.set('pendingActions', state.pendingActions);
    Store.set('activityLog', state.activityLog);
    Store.set('currentUser', state.currentUser);

    // --- GOOGLE FIREBASE REALTIME DATABASE ---
    const sendToFirebase = () => {
        if(window.isFirebaseActive) {
            window.db.ref('gameforge').set({
                users: state.users,
                tasks: state.tasks,
                pendingActions: state.pendingActions,
                activityLog: state.activityLog
            }).catch(e => console.error("Firebase kayıt hatası:", e));
        }
    };
    sendToFirebase();
};

// --- FIREBASE KURULUMU (SERVER) ---
// DİKKAT: Firebase'in çalışması için Google Firebase'den aldığın ayarları aşağıya yapıştır!
const firebaseConfig = {
  apiKey: "AIzaSyBlJZoZrnq4r09WN7cLCnG0LfTFBm_sNj8",
  authDomain: "gameforge-portal.firebaseapp.com",
  databaseURL: "https://gameforge-portal-default-rtdb.firebaseio.com",
  projectId: "gameforge-portal",
  storageBucket: "gameforge-portal.firebasestorage.app",
  messagingSenderId: "796460548515",
  appId: "1:796460548515:web:2808400d787d62cd7b5a16"
};

window.isFirebaseActive = false;

if(firebaseConfig.apiKey !== "BURAYA_API_KEY_YAZIN") {
    try {
        firebase.initializeApp(firebaseConfig);
        window.db = firebase.database();
        window.isFirebaseActive = true;
        
        const statusBadge = document.getElementById('server-status');
        if(statusBadge) {
            statusBadge.innerText = "FIREBASE: BAĞLI";
            statusBadge.classList.replace('offline', 'online');
        }

        // Real-time "Canlı İzleme" Listener
        window.db.ref('gameforge').on('value', (snapshot) => {
            const cloudData = snapshot.val() || {}; // Ensure we don't crash on null

            // VERY IMPORTANT: Firebase strips empty arrays. We MUST use || [] to prevent ghosting deleted items!
            state.users = cloudData.users || [];
            state.tasks = cloudData.tasks || [];
            state.pendingActions = cloudData.pendingActions || [];
            state.activityLog = cloudData.activityLog || [];
                
            Store.set('users', state.users);
            Store.set('tasks', state.tasks);
            Store.set('pendingActions', state.pendingActions);
            Store.set('activityLog', state.activityLog);

            if(!views.dashboard.classList.contains('hidden')) {
                renderDashboard();
            }
        });

        console.log("GameForge Server: Firebase Real-time DB Bağlandı!");
    } catch(e) {
        console.error("Firebase Kurulum Hatası:", e);
    }
} else {
    // Sadece yerel mod uyarısı
    const statusBadge = document.getElementById('server-status');
    if(statusBadge) {
        statusBadge.innerText = "SERVER KAPALI (KEY EKSİK)";
        statusBadge.classList.replace('online', 'offline');
    }
    console.warn("UYARI: Firebase Key girilmediği için sistem sadece kendi hafızasında çalışıyor.");
    setTimeout(() => {
        showNotice('warn', 'Firebase API ayarlarınızı main.js içine eklemelisiniz!');
    }, 2000);
}

// Pulse to keep session alive and update online status
setInterval(() => {
    if(state.currentUser) {
        saveState();
        if(views.dashboard.classList.contains('active') || !views.dashboard.classList.contains('hidden')) {
            renderTeam(); // Refresh online statuses periodically
        }
    }
}, 10000); 

// --- VIEW MANAGEMENT ---
// Manual Sync Button
const syncBtn = document.getElementById('manual-sync-btn');
if(syncBtn) {
    syncBtn.addEventListener('click', () => {
        showNotice('success', 'Bulut verileri tazeleniyor...');
        if(window.isCloudActive) {
            saveState(); // Push our latest
            // Gun.js handles the pull automatically via the 'on' listeners we already have.
            location.hash = ''; // Just a tiny trigger
        }
    });
}

// --- UI UTILITIES ---
window.togglePassword = (id) => {
    const input = document.getElementById(id);
    if(input.type === 'password') {
        input.type = 'text';
    } else {
        input.type = 'password';
    }
};

const showNotice = (type, msg) => {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = msg;
    container.appendChild(toast);
    setTimeout(() => {
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
};

const renderTeam = (filter = '') => {
    const list = document.getElementById('team-list');
    const now = Date.now();
    const isAdmin = state.currentUser && state.currentUser.role === 'admin';
    
    const filteredUsers = state.users.filter(u => 
        u.username.toLowerCase().includes(filter.toLowerCase()) || 
        u.dept.toLowerCase().includes(filter.toLowerCase())
    );

    list.innerHTML = filteredUsers.map(u => {
        const isOnline = (now - (u.lastSeen || 0)) < 30000;
        const isMe = state.currentUser && u.username === state.currentUser.username;
        const userActiveTasks = state.tasks.filter(t => t.assignee === u.username && !t.done).length;
        const deptInfo = departments.find(d => d.name === u.dept);
        const emoji = deptInfo ? deptInfo.emoji : '👤';
        
        return `
            <div class="user-card glass ${isMe ? 'me-card' : ''}">
                <div class="user-avatar" style="border-color: ${isMe ? 'var(--accent-pink)' : 'var(--accent-cyan)'}">
                    ${u.username[0].toUpperCase()}
                    <span class="status-dot ${isOnline ? 'online' : 'offline'}"></span>
                </div>
                <h4 style="color:${isMe ? 'var(--accent-pink)' : 'var(--accent-cyan)'}">${u.username} ${isMe ? '(Siz)' : ''}</h4>
                <p style="font-size:10px; color:var(--text-secondary); margin-bottom: 5px;">${emoji} ${u.dept}</p>
                
                <div class="user-task-badge" style="background: rgba(255,255,255,0.05); padding: 5px 10px; border-radius: 20px; font-size: 10px; margin-bottom: 10px;">
                    <span style="color: ${userActiveTasks > 0 ? 'var(--accent-cyan)' : 'var(--text-secondary)'}">
                        ${userActiveTasks} Aktif Görev
                    </span>
                </div>

                <div style="display: flex; flex-direction: column; gap: 8px; align-items: center;">
                    <span class="${isOnline ? 'online-text' : 'offline-text'}">
                        ${isOnline ? '● ÇEVRİMİÇİ' : '○ ÇEVRİMDIŞI'}
                    </span>
                    <div style="display:flex; gap:5px">
                        ${!isMe ? `<button onclick="mockMessage('${u.username}')" class="btn-outline-sm" style="font-size: 9px; padding: 4px 10px;">MESAJ</button>` : ''}
                        ${isAdmin && !isMe ? `<button onclick="deleteUserUI('${u.username}')" class="btn-outline-sm" style="font-size: 9px; padding: 4px 10px; color:#FF2D78; border-color:#FF2D78;">SİL</button>` : ''}
                    </div>
                </div>
                <p style="font-size:11px; margin-top:8px; opacity:0.7">${u.role === 'admin' ? '🛡️ Commander' : '👤 Personel'}</p>
            </div>
        `;
    }).join('');
    // ... rest of the logs remains same
};

// Global User Deletion UI
window.deleteUserUI = (username) => {
    if(confirm(`${username} isimli kullanıcıyı silmek istediğinize emin misiniz?`)) {
        requestAction('DELETE_USER', { username });
    }
};

// Mock Messaging
window.mockMessage = (targetUser) => {
    const chatWindow = document.getElementById('chat-window');
    const chatBadge = document.querySelector('.chat-badge');
    chatWindow.classList.remove('hidden');
    if(chatBadge) chatBadge.style.display = 'none';
    
    addMessage(`${targetUser} komutanı ile güvenli hat kuruldu. Mesajınızı buraya yazabilirsiniz.`, 'bot');
};
const views = {
    landing: document.getElementById('landing-view'),
    login: document.getElementById('login-view'),
    signup: document.getElementById('signup-view'),
    dashboard: document.getElementById('dashboard-view')
};

const showView = (viewName) => {
    Object.keys(views).forEach(key => views[key].classList.add('hidden'));
    views[viewName].classList.remove('hidden');
    window.scrollTo(0, 0);
};

// --- AUTH LOGIC ---
const updateAuthUI = () => {
    if(!state.currentUser) return;
    document.getElementById('user-info-text').innerText = `Oturum Sahibi: ${state.currentUser.username} (${state.currentUser.dept})`;
    
    // Approval badge visibility for everyone
    const badge = document.getElementById('approval-badge');
    if(state.pendingActions.length > 0) {
        badge.classList.remove('hidden');
    } else {
        badge.classList.add('hidden');
    }
};

// Signup
document.getElementById('do-signup').addEventListener('click', () => {
    const user = document.getElementById('signup-user').value.trim();
    const pass = document.getElementById('signup-pass').value.trim();
    const dept = document.getElementById('signup-dept').value;

    if(!user || !pass) return alert('Lütfen tüm alanları doldurun!');
    if(state.users.find(u => u.username === user)) return alert('Bu kullanıcı adı zaten alınmış!');

    const newUser = { username: user, password: pass, dept, role: 'staff' };
    state.users.push(newUser);
    
    logActivity(user, 'Sisteme kayıt oldu.', 'info');
    saveState();
    alert('Kayıt Başarılı! Şimdi giriş yapabilirsiniz.');
    showView('login');
});

// Login
document.getElementById('do-login').addEventListener('click', () => {
    const userVal = document.getElementById('login-email').value.trim();
    const passVal = document.getElementById('login-pass').value.trim();
    const btn = document.getElementById('do-login');

    const found = state.users.find(u => u.username === userVal && u.password === passVal);

    if(!found) return alert('Hatalı kullanıcı adı veya şifre!');

    btn.innerText = 'DOĞRULANIYOR...';
    btn.disabled = true;

    setTimeout(() => {
        state.currentUser = found;
        saveState();
        btn.innerText = 'OTURUMU BAŞLAT';
        btn.disabled = false;
        showView('dashboard');
        updateAuthUI();
        renderDashboard();
    }, 1200);
});

document.getElementById('do-logout').addEventListener('click', () => {
    state.currentUser = null;
    saveState();
    showView('landing');
});

// Navigation
document.getElementById('nav-portal').addEventListener('click', (e) => { e.preventDefault(); showView('login'); });
document.getElementById('hero-portal').addEventListener('click', (e) => { e.preventDefault(); showView('login'); });
document.getElementById('go-to-signup').addEventListener('click', (e) => { e.preventDefault(); showView('signup'); });
document.getElementById('go-to-login').addEventListener('click', (e) => { e.preventDefault(); showView('login'); });
document.getElementById('back-to-landing').addEventListener('click', (e) => { e.preventDefault(); showView('landing'); });

// --- DASHBOARD LOGIC ---
const departments = [
    { name: "FİKİR VE KONSEPT", emoji: "💡", color: "#FFEB3B", desc: "Zihin Haritası ve Konsept Art" },
    { name: "OYUN DİZAYNI", emoji: "🎮", color: "#00E5FF", desc: "Mekanik ve Sistem Dizaynı" },
    { name: "YAZILIM", emoji: "⚙️", color: "#00FF9D", desc: "Engine ve Mekanik Kodlama" },
    { name: "TASARIM", emoji: "🎨", color: "#8B5CFF", desc: "3D Modelleme ve UI" },
    { name: "HİKAYE VE LORE", emoji: "📜", color: "#FF9800", desc: "Senaryo ve Dünya İnşası" },
    { name: "SEVİYE TASARIMI", emoji: "🏔️", color: "#4CAF50", desc: "Level ve Çevre Tasarımı" },
    { name: "SES", emoji: "🎵", color: "#FFD700", desc: "Audio ve SFX" },
    { name: "KALİTE GÜVENCE", emoji: "🛡️", color: "#FF2D78", desc: "Hata Ayıklama" },
    { name: "ÜRETİM", emoji: "📋", color: "#607D8B", desc: "Planlama ve Yönetim" },
    { name: "PAZARLAMA VE PR", emoji: "📢", color: "#E91E63", desc: "Tanıtım ve Sosyal Medya" }
];

// Tabs
document.querySelectorAll('.dash-tab').forEach(tab => {
    tab.addEventListener('click', (e) => {
        document.querySelectorAll('.dash-tab').forEach(t => t.classList.remove('active'));
        e.target.classList.add('active');
        
        const mod = e.target.getAttribute('data-mod');
        document.querySelectorAll('.dash-module').forEach(m => m.classList.add('hidden'));
        document.getElementById('mod-' + mod).classList.remove('hidden');
        document.getElementById('mod-' + mod).classList.add('active');
        document.getElementById('dash-title').innerText = e.target.innerText.split(' ')[0];
        renderDashboard();
    });
});

// Modals
const modalTask = document.getElementById('task-modal');
const modalReject = document.getElementById('reject-modal');

document.getElementById('add-task-btn').addEventListener('click', () => modalTask.classList.remove('hidden'));
document.querySelectorAll('.modal-close').forEach(b => b.addEventListener('click', () => {
    modalTask.classList.add('hidden');
    modalReject.classList.add('hidden');
}));

// Action System (Pending)
const requestAction = (type, data) => {
    const action = {
        id: Date.now(),
        type,
        data,
        user: state.currentUser.username,
        time: new Date().toLocaleTimeString()
    };
    
    if(state.currentUser.role === 'admin') {
        processAction(action);
    } else {
        state.pendingActions.push(action);
        logActivity(state.currentUser.username, `${type} onaya gönderildi.`, 'warn');
        saveState();
        showNotice('warn', 'İşleminiz komutan onayına gönderildi.');
    }
    renderDashboard();
    modalTask.classList.add('hidden');
};

const processAction = (action) => {
    if(action.type === 'ADD') {
        const pVal = action.data.progress || 0;
        const newTask = { ...action.data, id: Date.now(), assignee: action.user, done: false, status: 'AKTİF', progress: pVal };
        state.tasks.push(newTask);
        logActivity(action.user, `Yeni görev eklendi: ${newTask.title}`, 'success');
        showNotice('success', 'Yeni görev başarıyla eklendi.');
    } else if(action.type === 'DELETE') {
        state.tasks = state.tasks.filter(t => t.id != action.data.id);
        logActivity(action.user, `Görev silindi.`, 'danger');
        showNotice('error', 'Görev silindi.');
    } else if(action.type === 'UPDATE_PROGRESS') {
        const task = state.tasks.find(t => t.id == action.data.id);
        if(task) {
            task.progress = action.data.progress;
            if(task.progress >= 100) {
                task.done = true;
                task.status = 'TAMAMLANDI';
                task.progress = 100;
            } else {
                task.done = false;
                task.status = 'AKTİF';
            }
            logActivity(action.user, `İlerleme güncellendi: ${task.title} (%${task.progress})`, 'info');
        }
    } else if(action.type === 'COMPLETE') {
        const task = state.tasks.find(t => t.id === action.data.id);
        if(task) {
            task.done = true;
            task.status = 'TAMAMLANDI';
            logActivity(action.user, `Görev tamamlandı: ${task.title}`, 'success');
            showNotice('success', 'Görev tamamlandı!');
        }
    } else if(action.type === 'REACTIVATE') {
        const task = state.tasks.find(t => t.id === action.data.id);
        if(task) {
            task.done = false;
            task.status = 'AKTİF';
            logActivity(action.user, `Görev tekrar açıldı: ${task.title}`, 'warn');
            showNotice('warn', 'Görev tekrar aktifleştirildi.');
        }
    } else if(action.type === 'DELETE_USER') {
        state.users = state.users.filter(u => u.username !== action.data.username);
        logActivity(action.user, `${action.data.username} ekibi terk etti.`, 'danger');
        showNotice('error', 'Kullanıcı kalıcı olarak silindi.');
    }
    saveState();
};

const logActivity = (user, message, type) => {
    state.activityLog.unshift({ user, message, type, time: new Date().toLocaleTimeString() });
    if(state.activityLog.length > 20) state.activityLog.pop();
};

// Admin Commands
window.approveAction = (id) => {
    const idx = state.pendingActions.findIndex(a => a.id === id);
    if(idx > -1) {
        const action = state.pendingActions[idx];
        processAction(action);
        state.pendingActions.splice(idx, 1);
        saveState();
        renderDashboard();
        updateAuthUI();
    }
};

let currentRejectId = null;
window.openReject = (id) => {
    currentRejectId = id;
    modalReject.classList.remove('hidden');
};

document.getElementById('confirm-reject').addEventListener('click', () => {
    const reason = document.getElementById('reject-reason').value;
    const idx = state.pendingActions.findIndex(a => a.id === currentRejectId);
    if(idx > -1) {
        const action = state.pendingActions[idx];
        logActivity('ADMIN', `${action.user} kişisinin işlemi reddedildi: ${reason}`, 'danger');
        state.pendingActions.splice(idx, 1);
        saveState();
        modalReject.classList.add('hidden');
        renderDashboard();
        updateAuthUI();
    }
});

// Task Interactions
window.handleTaskTitleClick = (id) => {
    const task = state.tasks.find(t => t.id === id);
    if(!task) return;
    
    if(task.done) {
        if(confirm('Bu görevi tekrar aktif etmek (Geri Al) istiyor musunuz?')) {
            requestAction('REACTIVATE', { id });
        }
    } else {
        requestAction('COMPLETE', { id });
    }
};

window.deleteTaskUI = (id) => {
    requestAction('DELETE', { id });
};

document.getElementById('save-task').addEventListener('click', () => {
    const title = document.getElementById('task-title').value;
    const dept = document.getElementById('task-dept').value;
    const priority = document.getElementById('task-priority').value;
    const progress = parseInt(document.getElementById('task-progress').value) || 0;
    if(!title) return alert('Başlık boş olamaz!');
    
    requestAction('ADD', { title, dept, priority, critical: priority === 'KRİTİK', progress });
    
    // Reset Form
    document.getElementById('task-title').value = '';
    document.getElementById('task-progress').value = 0;
    document.getElementById('progress-val-label').innerText = '%0';
});

window.promptUpdateProgress = (id, currentVal) => {
    const newVal = prompt(`Yeni ilerleme yüzdesini girin (Mevcut: %${currentVal})`, currentVal);
    if(newVal !== null && !isNaN(newVal)) {
        let p = parseInt(newVal);
        if(p < 0) p = 0;
        if(p > 100) p = 100;
        requestAction('UPDATE_PROGRESS', { id, progress: p });
    }
};

// --- RENDERERS ---
const renderDashboard = () => {
    renderGeneral();
    renderDepts();
    renderAllTasks();
    renderTeam();
    renderAdmin();
};

const renderGeneral = () => {
    const list = document.getElementById('critical-tasks-list');
    const criticals = state.tasks.filter(t => t.critical && !t.done);
    list.innerHTML = criticals.map(t => `
        <div class="task-item">
            <div class="task-info">
                <h4>${t.title}</h4>
                <span class="task-dept">${t.dept} (Sorumlu: ${t.assignee})</span>
            </div>
            <div class="task-meta">
                <span class="task-status" style="color:#FF2D78">${t.status}</span>
            </div>
        </div>
    `).join('') || '<p style="color:var(--text-secondary); text-align:center; padding:10px;">Şu an kritik görev bulunmuyor.</p>';
};

const renderDepts = () => {
    const list = document.getElementById('departments-list');
    list.innerHTML = departments.map(d => {
        const count = state.tasks.filter(t => t.dept === d.name && !t.done).length;
        return `
            <div class="dept-card" style="border-top: 3px solid ${d.color}">
                <div class="dept-card-header">
                    <span class="dept-icon">${d.emoji}</span>
                    <div class="dept-info"><h4>${d.name}</h4><p>${d.desc}</p></div>
                </div>
                <div class="dept-stats">
                    <div><div class="dept-label">AKTİF</div><div style="color:${d.color}" class="dept-task-count">${count}</div></div>
                </div>
            </div>
        `;
    }).join('');
};

const renderAllTasks = () => {
    const list = document.getElementById('all-tasks-list');
    if(!list) return;
    list.innerHTML = state.tasks.map(t => {
        const safeProg = parseInt(t.progress) || 0;
        return `
        <div class="task-item ${t.critical ? 'priority-high' : ''}" style="opacity: ${t.done ? 0.6 : 1}">
            <div class="task-info">
                <h4 style="text-decoration: ${t.done ? 'line-through' : 'none'}">${t.title}</h4>
                <span class="task-dept">${t.dept} | Sorumlu: ${t.assignee}</span>
                ${t.critical ? '<span style="font-size:9px; background:var(--accent-pink); color:white; padding:1px 5px; border-radius:3px; margin-left:10px">KRİTİK</span>' : ''}
                
                <div style="margin-top:10px; display:flex; align-items:center; gap:10px;">
                    <div style="flex-grow:1; height:8px; background:rgba(255,255,255,0.1); border-radius:4px; overflow:hidden; position:relative; cursor:pointer;" onclick="promptUpdateProgress(${t.id}, ${safeProg})" title="İlerlemeyi Güncelle">
                        <div style="width:${safeProg}%; height:100%; background:var(--accent-cyan); border-radius:4px; transition:width 0.3s ease;"></div>
                    </div>
                    <span style="font-size:10px; color:var(--accent-cyan); font-weight:bold">%${safeProg}</span>
                </div>
            </div>
            <div class="task-meta" style="display:flex; align-items:center; gap:12px">
                <span class="task-status" style="color: ${t.done ? '#00FF9D' : '#FF2D78'}">${t.status}</span>
                <div style="display:flex; gap:8px">
                    ${!t.done ? `<button onclick="handleTaskTitleClick(${t.id})" title="Bitir" style="background:#00FF9D; border:none; color:#09090F; cursor:pointer; font-size:14px; width:28px; height:28px; border-radius:6px; font-weight:bold">✔</button>` : ''}
                    <button onclick="deleteTaskUI(${t.id})" title="Sil" style="background:rgba(255,45,120,0.1); border:1px solid #FF2D78; color:#FF2D78; cursor:pointer; font-size:14px; width:28px; height:28px; border-radius:6px">🗑️</button>
                </div>
            </div>
        </div>
    `}).join('');
};

const renderAdmin = () => {
    const list = document.getElementById('pending-actions-list');
    if(!list) return;
    const isAdmin = state.currentUser && state.currentUser.role === 'admin';

    if(state.pendingActions.length === 0) {
        list.innerHTML = '<p style="color:var(--text-secondary); text-align:center; padding:20px;">Şu an bekleyen bir onay bulunmuyor.</p>';
        return;
    }

    list.innerHTML = state.pendingActions.map(a => {
        let details = '';
        if(a.type === 'ADD') details = `<strong>YENİ GÖREV:</strong> ${a.data.title}`;
        if(a.type === 'COMPLETE') {
            const task = state.tasks.find(t => t.id === a.data.id);
            details = `<strong>GÖREV BİTİRME:</strong> ${task ? task.title : 'Bilinmeyen Görev'}`;
        }
        if(a.type === 'DELETE') {
            const task = state.tasks.find(t => t.id === a.data.id);
            details = `<strong>GÖREV SİLME:</strong> ${task ? task.title : 'Bilinmeyen Görev'}`;
        }
        if(a.type === 'UPDATE_PROGRESS') {
            const task = state.tasks.find(t => t.id == a.data.id);
            details = `<strong>İLERLEME GÜNCELLEMESİ:</strong> ${task ? task.title : 'Bilinmeyen'} (Yeni: %${a.data.progress})`;
        }
        if(a.type === 'REACTIVATE') {
            const task = state.tasks.find(t => t.id === a.data.id);
            details = `<strong>YENİDEN AKTİFLEŞTİRME:</strong> ${task ? task.title : 'Bilinmeyen Görev'}`;
        }

        return `
            <div class="task-item glass" style="border-left: 3px solid var(--accent-gold); margin-bottom:10px;">
                <div class="task-info">
                    <span class="pending-badge">${a.type} TALEBİ</span>
                    <h4 style="margin-top:5px; font-size:14px;">${details}</h4>
                    <p style="font-size:11px; color:var(--text-secondary); margin-top:5px;">Talep Eden: ${a.user} | Saat: ${a.time}</p>
                </div>
                <div class="action-btns" style="margin-top:10px;">
                    ${isAdmin ? `
                        <button class="btn-approve" onclick="approveAction(${a.id})">ONAYLA</button>
                        <button class="btn-reject" onclick="openReject(${a.id})">REDDET</button>
                    ` : `
                        <span style="font-size:10px; color:var(--accent-gold); letter-spacing:1px; font-weight:700">KOMUTAN ONAYI BEKLENİYOR...</span>
                    `}
                </div>
            </div>
        `;
    }).join('');
};

// --- OTHERS ---
window.addEventListener('load', () => {
    const loader = document.getElementById('loader');
    if(loader) setTimeout(() => loader.classList.add('fade-out'), 1000);
    if(state.currentUser) {
        showView('dashboard');
        updateAuthUI();
        renderDashboard();
    }
});

// Particles & Chat logic preserved
if(window.particlesJS) {
    particlesJS('particles-js', {
      "particles": {
        "number": { "value": 60, "density": { "enable": true, "value_area": 800 } },
        "color": { "value": ["#00E5FF", "#8B5CFF", "#FF2D78"] },
        "shape": { "type": "circle" },
        "opacity": { "value": 0.5, "random": true, "anim": { "enable": true, "speed": 1, "opacity_min": 0.1, "sync": false } },
        "size": { "value": 3, "random": true, "anim": { "enable": false } },
        "line_linked": { "enable": true, "distance": 150, "color": "#00E5FF", "opacity": 0.2, "width": 1 },
        "move": { "enable": true, "speed": 2, "direction": "none", "random": true, "straight": false, "out_mode": "out", "bounce": false }
      },
      "interactivity": {
        "detect_on": "canvas",
        "events": { "onhover": { "enable": true, "mode": "grab" }, "onclick": { "enable": true, "mode": "push" }, "resize": true },
        "modes": { "grab": { "distance": 140, "line_linked": { "opacity": 0.8 } }, "push": { "particles_nb": 4 } }
      },
      "retina_detect": true
    });
}

// Chat Widget
const chatToggle = document.getElementById('chat-toggle');
if(chatToggle) {
    chatToggle.addEventListener('click', () => {
        document.getElementById('chat-window').classList.toggle('hidden');
        document.querySelector('.chat-badge').style.display = 'none';
    });
}
document.getElementById('chat-close').addEventListener('click', () => document.getElementById('chat-window').classList.add('hidden'));

const addMessage = (text, sender) => {
    const chatMessages = document.getElementById('chat-messages');
    const msgDiv = document.createElement('div');
    msgDiv.classList.add('msg', sender);
    const avatar = sender === 'bot' ? '⚡' : '👤';
    msgDiv.innerHTML = `<div class="avatar">${avatar}</div><div class="content">${text}</div>`;
    chatMessages.appendChild(msgDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
};

const handleSend = () => {
    const input = document.getElementById('user-input');
    const text = input.value.trim();
    if (text) {
        addMessage(text, 'user');
        input.value = '';
        setTimeout(() => {
            const responses = ["Mesajını aldım.", "Veriler güncelleniyor.", "Sistem %100 kapasiteyle çalışıyor."];
            addMessage(responses[Math.floor(Math.random() * responses.length)], 'bot');
        }, 800);
    }
};

document.getElementById('send-msg').addEventListener('click', handleSend);
document.getElementById('user-input').addEventListener('keypress', (e) => { if (e.key === 'Enter') handleSend(); });
