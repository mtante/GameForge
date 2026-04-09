// View Management
const views = {
    landing: document.getElementById('landing-view'),
    login: document.getElementById('login-view'),
    dashboard: document.getElementById('dashboard-view')
};

const showView = (viewName) => {
    Object.keys(views).forEach(key => {
        views[key].classList.add('hidden');
    });
    views[viewName].classList.remove('hidden');
    window.scrollTo(0, 0);
};

// Navigation Listeners
document.getElementById('nav-portal').addEventListener('click', (e) => {
    e.preventDefault();
    showView('login');
});

document.getElementById('hero-portal').addEventListener('click', (e) => {
    e.preventDefault();
    showView('login');
});

document.getElementById('back-to-landing').addEventListener('click', (e) => {
    e.preventDefault();
    showView('landing');
});

// Login Logic
document.getElementById('do-login').addEventListener('click', () => {
    const email = document.getElementById('login-email').value;
    const pass = document.getElementById('login-pass').value;
    const btn = document.getElementById('do-login');

    if(email !== 'admin' || pass !== 'atss19') {
        alert('Erişim Reddedildi: Geçersiz Komutan Kimliği veya Şifresi.');
        return;
    }

    btn.innerText = 'BAŞLATILIYOR...';
    btn.disabled = true;
    
    // Simulate auth delay
    setTimeout(() => {
        btn.innerText = 'OTURUMU BAŞLAT';
        btn.disabled = false;
        showView('dashboard');
        renderTasks();
    }, 1500);
});

document.getElementById('do-logout').addEventListener('click', () => {
    showView('landing');
});

// Dashboard Logic
let tasks = [
    { id: 1, title: "Ana karakter hareket mekaniği", dept: "YAZILIM", status: "AKTİF", progress: "%80", done: false, critical: true },
    { id: 2, title: "Bölüm 1 harita tasarımı", dept: "TASARIM", status: "AKTİF", progress: "%40", done: false, critical: true },
    { id: 3, title: "Düşman yapay zeka sistemi", dept: "YAZILIM", status: "AKTİF", progress: "%20", done: false, critical: true },
    { id: 4, title: "Ara sahne müzikleri", dept: "SES", status: "BEKLİYOR", progress: "%0", done: false, critical: false },
    { id: 5, title: "Optimizasyon testleri", dept: "KALİTE GÜVENCE", status: "İNCELEME", progress: "%90", done: false, critical: false },
    { id: 6, title: "Oyun içi satın alım arayüzü", dept: "TASARIM", status: "AKTİF", progress: "%60", done: false, critical: false }
];

const departments = [
    { name: "YAZILIM", emoji: "⚙️", count: 2, color: "var(--accent-cyan)", desc: "Oyun motoru, mekanikler ve yapay zeka." },
    { name: "TASARIM", emoji: "🎨", count: 2, color: "var(--accent-purple)", desc: "Konsept, 3D modeller ve UI tasarımı." },
    { name: "SES", emoji: "🎵", count: 1, color: "var(--accent-gold)", desc: "Müzik, efektler ve seslendirmeler." },
    { name: "KALİTE GÜVENCE", emoji: "🛡️", count: 1, color: "var(--accent-pink)", desc: "Hata bulma ve performans." }
];

// Tab Logic
document.querySelectorAll('.dash-tab').forEach(tab => {
    tab.addEventListener('click', (e) => {
        // Toggle tabs
        document.querySelectorAll('.dash-tab').forEach(t => t.classList.remove('active'));
        e.target.classList.add('active');
        
        // Show correct module
        const mod = e.target.getAttribute('data-mod');
        document.querySelectorAll('.dash-module').forEach(m => m.classList.add('hidden'));
        document.querySelectorAll('.dash-module').forEach(m => m.classList.remove('active'));
        
        const activeMod = document.getElementById('mod-' + mod);
        activeMod.classList.remove('hidden');
        activeMod.classList.add('active');

        // Update Title
        document.getElementById('dash-title').innerText = e.target.innerText;
    });
});

window.toggleTask = (id) => {
    const task = tasks.find(t => t.id === id);
    if(task) {
        task.done = !task.done;
        task.status = task.done ? "TAMAMLANDI" : "AKTİF";
        renderTasks();
    }
};

const renderTasks = () => {
    const criticalList = document.getElementById('critical-tasks-list');
    const allTasksList = document.getElementById('all-tasks-list');
    const deptsList = document.getElementById('departments-list');

    // Render Critical Tasks
    const criticalHtml = tasks.filter(t => t.critical).map(task => `
        <div class="task-item" style="cursor: pointer; border-color: ${task.done ? '#00FF9D' : 'rgba(255,255,255,0.05)'}; opacity: ${task.done ? '0.6' : '1'}; transition: all 0.3s;" onclick="toggleTask(${task.id})">
            <div class="task-info">
                <h4 style="text-decoration: ${task.done ? 'line-through' : 'none'}">${task.title}</h4>
                <span class="task-dept">${task.dept}</span>
            </div>
            <div class="task-meta">
                <span class="task-status" style="color: ${task.done ? '#00FF9D' : '#FF2D78'}">${task.done ? "TAMAM" : task.progress}</span>
            </div>
        </div>
    `).join('');
    criticalList.innerHTML = criticalHtml || '<p style="color:var(--text-secondary)">Kritik görev bulunmuyor.</p>';

    // Render All Tasks
    allTasksList.innerHTML = tasks.map(task => `
        <div class="task-item" style="cursor: pointer; border-color: ${task.done ? '#00FF9D' : 'rgba(255,255,255,0.05)'}; opacity: ${task.done ? '0.6' : '1'}; transition: all 0.3s;" onclick="toggleTask(${task.id})">
            <div class="task-info">
                <h4 style="text-decoration: ${task.done ? 'line-through' : 'none'}">${task.title}</h4>
                <span class="task-dept">${task.dept}</span>
            </div>
            <div class="task-meta">
                <span class="task-status" style="color: ${task.done ? '#00FF9D' : 'var(--text-secondary)'}">${task.status}</span>
            </div>
        </div>
    `).join('');

    // Render Departments
    deptsList.innerHTML = departments.map(d => {
        // dynamic count
        const activeCount = tasks.filter(t => t.dept === d.name && !t.done).length;
        
        return `
        <div class="dept-card" style="border-top: 3px solid ${d.color}">
            <div class="dept-card-header">
                <span class="dept-icon">${d.emoji}</span>
                <div class="dept-info">
                    <h4 style="color: ${d.color}">${d.name}</h4>
                    <p>${d.desc}</p>
                </div>
            </div>
            <div class="dept-stats">
                <div>
                    <div class="dept-label">AKTİF GÖREV</div>
                    <div class="dept-task-count" style="color: ${d.color}">${activeCount}</div>
                </div>
            </div>
        </div>
    `}).join('');
};

// Loader Logic
window.addEventListener('load', () => {
    const loader = document.getElementById('loader');
    setTimeout(() => {
        loader.classList.add('fade-out');
    }, 1500);
});

// Chat Widget Logic
const chatToggle = document.getElementById('chat-toggle');
const chatClose = document.getElementById('chat-close');
const chatWindow = document.getElementById('chat-window');
const chatMessages = document.getElementById('chat-messages');
const userInput = document.getElementById('user-input');
const sendBtn = document.getElementById('send-msg');
const chatBadge = document.querySelector('.chat-badge');

chatToggle.addEventListener('click', () => {
    chatWindow.classList.toggle('hidden');
    chatBadge.style.display = 'none';
});

chatClose.addEventListener('click', () => {
    chatWindow.classList.add('hidden');
});

const addMessage = (text, sender) => {
    const msgDiv = document.createElement('div');
    msgDiv.classList.add('msg', sender);
    
    const avatar = sender === 'bot' ? '⚡' : '👤';
    
    msgDiv.innerHTML = `
        <div class="avatar">${avatar}</div>
        <div class="content">${text}</div>
    `;
    
    chatMessages.appendChild(msgDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
};

const handleSend = () => {
    const text = userInput.value.trim();
    if (text) {
        addMessage(text, 'user');
        userInput.value = '';
        
        // Mock simulated response
        setTimeout(() => {
            const responses = [
                "Mesajını geliştirici ekibine ilettim. Lütfen beklemede kal.",
                "Görev parametreleri güncellendi. İnceliyoruz.",
                "Proje istihbarat verilerine erişiliyor... lütfen bekle.",
                "Forge şu anda %95 verimlilikte çalışıyor. Tüm sistemler yeşil."
            ];
            const randomResponse = responses[Math.floor(Math.random() * responses.length)];
            addMessage(randomResponse, 'bot');
        }, 1000);
    }
};

sendBtn.addEventListener('click', handleSend);
userInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') handleSend();
});

// Smooth Scroll
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

// Initial greeting after 3 seconds
setTimeout(() => {
    if (chatWindow.classList.contains('hidden')) {
        chatBadge.style.display = 'flex';
    }
}, 3000);

// Particles JS Initialization
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
