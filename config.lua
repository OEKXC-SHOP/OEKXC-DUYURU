Config = {}

-- Framework seçimi ('esx' veya 'qbcore')
Config.Framework = 'qbcore'

-- Admin grupları (ESX için)
Config.ESXAdminGroups = {
    ['superadmin'] = true,
    ['admin'] = true
}

-- Admin permission seviyeleri (QBCore için)
Config.QBPermissions = {
    ['god'] = true,
    ['admin'] = true
}

-- Duyuru ayarları
Config.Settings = {
    Command = 'duyuru',           -- Duyuru panelini açma komutu
    DisplayTime = 5000,           -- Duyurunun ekranda kalma süresi (ms)
    MaxHistory = 50              -- Gösterilecek maksimum geçmiş duyuru sayısı
}

-- Duyuru metni formatı
Config.AnnouncementFormat = {
    Prefix = '^3[DUYURU] ^7',    -- Duyuru öneki (^7 beyaz, ^3 sarı renk)
    AdminNameColor = '^5'         -- Admin ismi rengi (^5 mavi)
}

-- Duyuru önem seviyeleri ve renkleri
Config.ImportanceLevels = {
    low = {
        label = 'Düşük Önem',
        color = {
            primary = '#3498db',      -- Mavi tonu
            secondary = '#2980b9'     -- Koyu mavi
        }
    },
    medium = {
        label = 'Orta Önem',
        color = {
            primary = '#f1c40f',      -- Sarı tonu
            secondary = '#f39c12'     -- Koyu sarı
        }
    },
    high = {
        label = 'Yüksek Önem',
        color = {
            primary = '#e74c3c',      -- Kırmızı tonu
            secondary = '#c0392b'     -- Koyu kırmızı
        }
    }
}
