let container = document.getElementById('container');
let announcementsContainer = null;
let selectedImportance = 'low';

// Duyuru container'ı oluşturma
function createAnnouncementsContainer() {
    if (!announcementsContainer) {
        announcementsContainer = document.createElement('div');
        announcementsContainer.id = 'announcements-container';
        document.body.appendChild(announcementsContainer);
    }
    return announcementsContainer;
}

// Önem seviyesi butonları için event listener'lar
document.querySelectorAll('.importance-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        // Aktif butonu güncelle
        document.querySelectorAll('.importance-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        selectedImportance = btn.dataset.level;
    });
});

window.addEventListener('message', function(event) {
    let data = event.data;

    switch(data.type) {
        case "ui":
            container.style.display = data.status ? "flex" : "none";
            break;
            
        case "announcement":
            showAnnouncementDisplay(data.message, data.admin, data.importance, data.displayTime);
            break;
            
        case "history":
            updateHistory(data.data);
            break;
    }
});

document.getElementById('close-btn').addEventListener('click', function() {
    container.style.display = "none";
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
});

document.getElementById('send-btn').addEventListener('click', function() {
    let text = document.getElementById('announcement-text').value.trim();
    
    if (text) {
        fetch(`https://${GetParentResourceName()}/sendAnnouncement`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                message: text,
                importance: selectedImportance
            })
        }).then(() => {
            document.getElementById('announcement-text').value = '';
            setTimeout(() => {
                container.style.display = "none";
                fetch(`https://${GetParentResourceName()}/close`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: JSON.stringify({})
                });
            }, 100);
        });
    }
});

function showAnnouncementDisplay(message, admin, importance = 'low', displayTime = 5000) {
    const container = createAnnouncementsContainer();
    const display = document.createElement('div');
    
    // Mesaj uzunluğuna göre sınıf belirleme
    let lengthClass = 'length-short';
    if (message.length > 150) {
        lengthClass = 'length-long';
    } else if (message.length > 80) {
        lengthClass = 'length-medium';
    }
    
    display.className = `announcement-display ${importance} ${lengthClass}`;
    
    display.innerHTML = `
        <div class="icon">📢</div>
        <div class="announcement-content">
            <div class="admin-name">${admin}</div>
            <div class="message">${message}</div>
        </div>
        <button class="close-btn">✕</button>
        <div class="progress-bar"></div>
    `;
    
    // Çarpı butonuna tıklama olayı
    const closeBtn = display.querySelector('.close-btn');
    closeBtn.addEventListener('click', () => {
        display.classList.add('removing');
        setTimeout(() => {
            display.remove();
            if (container.children.length === 0) {
                container.remove();
                announcementsContainer = null;
            }
        }, 500);
    });
    
    container.appendChild(display);
    
    setTimeout(() => {
        display.classList.add('removing');
        setTimeout(() => {
            display.remove();
            if (container.children.length === 0) {
                container.remove();
                announcementsContainer = null;
            }
        }, 500);
    }, displayTime);
}

// Karakter sayacı için event listener
const textarea = document.getElementById('announcement-text');
const charCount = document.getElementById('char-count');

textarea.addEventListener('input', function() {
    const length = this.value.length;
    charCount.textContent = length;
    
    // Karakter limiti yaklaştığında uyarı efekti
    if (length >= 200) {
        charCount.style.color = '#ff4757';
    } else {
        charCount.style.color = 'rgba(255, 255, 255, 0.6)';
    }
});

function updateHistory(history) {
    const historyContainer = document.getElementById('announcement-history');
    historyContainer.innerHTML = '';
    
    history.forEach(item => {
        const historyItem = document.createElement('div');
        historyItem.className = `history-item ${item.importance_level}`;
        historyItem.innerHTML = `
            <div class="admin-name">${item.admin_name}</div>
            <div class="message">${item.message}</div>
            <div class="date">${new Date(item.created_at).toLocaleString('tr-TR')}</div>
        `;
        
        historyItem.addEventListener('click', () => {
            const message = item.message.substring(0, 250);
            document.getElementById('announcement-text').value = message;
            // Karakter sayacını güncelle
            charCount.textContent = message.length;
            if (message.length >= 200) {
                charCount.style.color = '#ff4757';
            } else {
                charCount.style.color = 'rgba(255, 255, 255, 0.6)';
            }
            
            // Önem seviyesini de seç
            const importanceBtn = document.querySelector(`.importance-btn[data-level="${item.importance_level}"]`);
            if (importanceBtn) {
                document.querySelectorAll('.importance-btn').forEach(b => b.classList.remove('active'));
                importanceBtn.classList.add('active');
                selectedImportance = item.importance_level;
            }
        });
        
        historyContainer.appendChild(historyItem);
    });
}

// ESC tuşu ile paneli kapatma
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && container.style.display === "flex") {
        container.style.display = "none";
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
    }
});
