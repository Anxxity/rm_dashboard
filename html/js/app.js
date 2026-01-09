let currentPlayerId = null;
let playersData = [];

// hide dashboard
document.querySelector('.dashboard-container').style.display = 'none';

// GV
let allPlayersData = [];
let currentPage = 1;
let entriesPerPage = 25;
let currentSortColumn = -1;
let sortDirection = 'asc';

// Initialize dashboard
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'open') {
        document.querySelector('.dashboard-container').style.display = 'flex';
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('activity-date').value = today;
        refreshStatistics();
        loadAllPlayersDB();
    } else if (data.type === 'getPlayersResponse') {
        handleGetPlayersResponse(data.data);
    } else if (data.type === 'getPlayerDetailsResponse') {
        handleGetPlayerDetailsResponse(data.data);
    } else if (data.type === 'updatePlayerMoneyResponse') {
        handleUpdatePlayerMoneyResponse(data.data);
    } else if (data.type === 'setPlayerMoneyResponse') {
        handleSetPlayerMoneyResponse(data.data);
    } else if (data.type === 'executeSQLResponse') {
        handleExecuteSQLResponse(data.data);
    } else if (data.type === 'getStatisticsResponse') {
        handleGetStatisticsResponse(data.data);
    } else if (data.type === 'getAllPlayersDBResponse') {
        handleGetAllPlayersDBResponse(data.data);
    } else if (data.type === 'getPlayerInventoryResponse') {
        handleGetPlayerInventoryResponse(data.data);
    } else if (data.type === 'getActivityResponse') {
        handleGetActivityResponse(data.data);
    } else if (data.type === 'getPlayerVehiclesResponse') {
        handleGetPlayerVehiclesResponse(data.data);
    } else if (data.type === 'changePlayerJobResponse') {
        handleChangePlayerJobResponse(data.data);
    }
});


function openTab(tabName) {

    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    

    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    

    document.getElementById(tabName + '-tab').classList.add('active');

    document.querySelectorAll('.tab-btn').forEach(btn => {
        if (btn.getAttribute('data-tab') === tabName) {
            btn.classList.add('active');
        } else {
            btn.classList.remove('active');
        }
    });
    
    if (tabName === 'economy') {
        populateEconomyPlayerSelect();
    } else if (tabName === 'principal') {
        refreshStatistics();
        loadAllPlayersDB();
    } else if (tabName === 'activity') {
        loadActivity();
    }
}


function closeDashboard() {
    document.querySelector('.dashboard-container').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(err => console.error('Error closing dashboard:', err));
}

function GetParentResourceName() {
    return 'rm_dashboard';
}

// notification
function showNotification(message, isError = false) {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.className = 'notification' + (isError ? ' error' : '');
    notification.classList.add('show');
    
    setTimeout(() => {
        notification.classList.remove('show');
    }, 3000);
}

// Fetch p
function refreshPlayers() {
    const playersList = document.getElementById('players-list');
    playersList.innerHTML = '<div class="loading">Loading players...</div>';
    
    fetch(`https://${GetParentResourceName()}/getPlayers`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(error => {
        playersList.innerHTML = '<div class="loading" style="color: #e74c3c;">Error loading players</div>';
        console.error('Error:', error);
    });
}

// players response
function handleGetPlayersResponse(data) {
    const playersList = document.getElementById('players-list');
    if (data.success) {
        playersData = data.players;
        displayPlayers(data.players);
    } else {
        playersList.innerHTML = '<div class="loading" style="color: #e74c3c;">Error: ' + data.error + '</div>';
    }
}

// Display players
function displayPlayers(players) {
    const playersList = document.getElementById('players-list');
    
    if (players.length === 0) {
        playersList.innerHTML = '<div class="loading">No players online</div>';
        return;
    }
    
    playersList.innerHTML = players.map(player => `
        <div class="player-card" onclick="viewPlayerDetails(${player.id})">
            <h3>${player.name}</h3>
            <div class="player-info">
                <div class="info-row">
                    <span class="info-label">ID:</span>
                    <span class="info-value">${player.id}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Cash:</span>
                    <span class="info-value">$${formatNumber(player.money)}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Bank:</span>
                    <span class="info-value">$${formatNumber(player.bank)}</span>
                </div>
                <div class="info-row">
                    <span class="info-label">Job:</span>
                    <span class="info-value">${player.jobLabel || player.job}</span>
                </div>
            </div>
        </div>
    `).join('');
}

// player details
function viewPlayerDetails(playerId) {
    fetch(`https://${GetParentResourceName()}/getPlayerDetails`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ playerId: playerId })
    }).catch(error => {
        showNotification('Error loading player details', true);
        console.error('Error:', error);
    });
}

//player details response
function handleGetPlayerDetailsResponse(data) {
    if (data.success) {
        currentPlayerId = data.player.id;
    
        const economyTab = document.getElementById('economy-tab');
        if (!economyTab.classList.contains('active')) {
            openTab('economy');
            document.querySelector('.tab-btn:nth-child(2)').classList.add('active');
            document.querySelector('.tab-btn:nth-child(1)').classList.remove('active');
        }
        
        loadPlayerEconomyData(data.player);
        document.getElementById('economy-player-select').value = data.player.id;
    } else {
        showNotification('Error: ' + data.error, true);
    }
}


function populateEconomyPlayerSelect() {
    const select = document.getElementById('economy-player-select');
    select.innerHTML = '<option value="">-- Select Player --</option>';
    
    playersData.forEach(player => {
        const option = document.createElement('option');
        option.value = player.id;
        option.textContent = `${player.name} (ID: ${player.id})`;
        select.appendChild(option);
    });
}

function loadPlayerEconomy() {
    const playerId = document.getElementById('economy-player-select').value;
    if (!playerId) {
        document.getElementById('player-economy-details').style.display = 'none';
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/getPlayerDetails`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ playerId: playerId })
    }).catch(error => {
        showNotification('Error loading player details', true);
        console.error('Error:', error);
    });
}

function loadPlayerEconomyData(player) {
    document.getElementById('economy-name').textContent = player.name;
    document.getElementById('economy-id').textContent = player.id;
    document.getElementById('economy-cash').textContent = '$' + formatNumber(player.money);
    document.getElementById('economy-bank').textContent = '$' + formatNumber(player.bank);
    document.getElementById('player-economy-details').style.display = 'block';
}

function addPlayerMoney() {
    if (!currentPlayerId) {
        showNotification('Please select a player first', true);
        return;
    }
    
    const moneyType = document.getElementById('add-money-type').value;
    const amount = document.getElementById('add-money-amount').value;
    
    if (!amount || amount <= 0) {
        showNotification('Please enter a valid amount', true);
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/updatePlayerMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            playerId: currentPlayerId,
            moneyType: moneyType,
            amount: amount
        })
    }).catch(error => {
        showNotification('Error updating money', true);
        console.error('Error:', error);
    });
}

function handleUpdatePlayerMoneyResponse(data) {
    if (data.success) {
        showNotification(data.message || 'Money added successfully');
        document.getElementById('add-money-amount').value = '';
        loadPlayerEconomy();
    } else {
        showNotification('Error: ' + data.error, true);
    }
}

function setPlayerMoney() {
    if (!currentPlayerId) {
        showNotification('Please select a player first', true);
        return;
    }
    
    const moneyType = document.getElementById('set-money-type').value;
    const amount = document.getElementById('set-money-amount').value;
    
    if (!amount || amount < 0) {
        showNotification('Please enter a valid amount', true);
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/setPlayerMoney`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            playerId: currentPlayerId,
            moneyType: moneyType,
            amount: amount
        })
    }).catch(error => {
        showNotification('Error setting money', true);
        console.error('Error:', error);
    });
}

function handleSetPlayerMoneyResponse(data) {
    if (data.success) {
        showNotification(data.message || 'Money set successfully');
        document.getElementById('set-money-amount').value = '';
        loadPlayerEconomy();
    } else {
        showNotification('Error: ' + data.error, true);
    }
}

function executeSQL() {
    const query = document.getElementById('sql-query').value.trim();
    
    if (!query) {
        showNotification('Please enter a SQL query', true);
        return;
    }
    
    const resultDiv = document.getElementById('sql-result');
    resultDiv.textContent = 'Executing query...';
    resultDiv.className = 'sql-result';
    
    fetch(`https://${GetParentResourceName()}/executeSQL`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ query: query })
    }).catch(error => {
        resultDiv.className = 'sql-result error';
        resultDiv.textContent = 'Error: ' + error.message;
        showNotification('Error executing query', true);
        console.error('Error:', error);
    });
}

function handleExecuteSQLResponse(data) {
    const resultDiv = document.getElementById('sql-result');
    if (data.success) {
        resultDiv.className = 'sql-result success';
        resultDiv.textContent = JSON.stringify(data.result, null, 2);
        showNotification('Query executed successfully');
    } else {
        resultDiv.className = 'sql-result error';
        resultDiv.textContent = 'Error: ' + data.error;
        showNotification('Error: ' + data.error, true);
    }
}

function clearSQL() {
    document.getElementById('sql-query').value = '';
    document.getElementById('sql-result').textContent = '';
    document.getElementById('sql-result').className = 'sql-result';
}

function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}


setInterval(() => {
    if (document.getElementById('players-tab').classList.contains('active')) {
        refreshPlayers();
    }
    if (document.getElementById('principal-tab').classList.contains('active')) {
        refreshStatistics();
    }
}, 5000);


function refreshStatistics() {
    fetch(`https://${GetParentResourceName()}/getStatistics`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    }).catch(err => console.error('Error:', err));
}

function handleGetStatisticsResponse(data) {
    if (data.success) {
        displayStatistics(data.statistics);
    }
}

function displayStatistics(stats) {
    const statsGrid = document.getElementById('stats-grid');
    statsGrid.innerHTML = `
        <div class="stat-card">
            <div class="stat-header">
                <h3>Total Players</h3>
                <span class="stat-icon">👥</span>
            </div>
            <div class="stat-value">${stats.totalPlayers || 0}</div>
            <div class="stat-footer">${stats.onlinePlayers || 0} Online</div>
        </div>
        <div class="stat-card">
            <div class="stat-header">
                <h3>Total Cash</h3>
                <span class="stat-icon">💵</span>
            </div>
            <div class="stat-value">$${formatNumber(stats.totalCash || 0)}</div>
            <div class="stat-footer">Server-wide cash</div>
        </div>
        <div class="stat-card">
            <div class="stat-header">
                <h3>Total Bank</h3>
                <span class="stat-icon">🏦</span>
            </div>
            <div class="stat-value">$${formatNumber(stats.totalBank || 0)}</div>
            <div class="stat-footer">Server-wide bank</div>
        </div>
        <div class="stat-card">
            <div class="stat-header">
                <h3>Sex Info</h3>
                <span class="stat-icon">⚧️</span>
            </div>
            <div class="stat-value">${stats.sexInfo?.total || 0}</div>
            <div class="stat-footer">
                <span style="color: #3b82f6;">${stats.sexInfo?.male || 0} Male</span> | 
                <span style="color: #ec4899;">${stats.sexInfo?.female || 0} Female</span>
            </div>
        </div>
    `;
}

function loadAllPlayersDB() {
    fetch(`https://${GetParentResourceName()}/getAllPlayersDB`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    }).catch(err => console.error('Error:', err));
}

function handleGetAllPlayersDBResponse(data) {
    if (data.success) {
        allPlayersData = data.players;
        displayPlayersTable();
    }
}

function displayPlayersTable() {
    const tbody = document.getElementById('players-table-body');
    const start = (currentPage - 1) * entriesPerPage;
    const end = start + entriesPerPage;
    const pageData = allPlayersData.slice(start, end);
    
    if (pageData.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="loading">No players found</td></tr>';
        return;
    }
    
    tbody.innerHTML = pageData.map(player => `
        <tr>
            <td>${player.identifier || '-'}</td>
            <td>${player.name || '-'}</td>
            <td>${player.icName || '-'}</td>
            <td>$${formatNumber(player.cash || 0)}</td>
            <td>$${formatNumber(player.bank || 0)}</td>
            <td>${player.job || '-'}</td>
        </tr>
    `).join('');
    
    updatePagination();
}

function changeEntriesPerPage() {
    entriesPerPage = parseInt(document.getElementById('entries-select').value);
    currentPage = 1;
    displayPlayersTable();
}

function searchTable() {
    const searchTerm = document.getElementById('search-input').value.toLowerCase();
    if (!searchTerm) {
        displayPlayersTable();
        return;
    }
    
    const filtered = allPlayersData.filter(player => 
        (player.identifier && player.identifier.toLowerCase().includes(searchTerm)) ||
        (player.name && player.name.toLowerCase().includes(searchTerm)) ||
        (player.icName && player.icName.toLowerCase().includes(searchTerm)) ||
        (player.job && player.job.toLowerCase().includes(searchTerm))
    );
    
    const tbody = document.getElementById('players-table-body');
    const start = (currentPage - 1) * entriesPerPage;
    const end = start + entriesPerPage;
    const pageData = filtered.slice(start, end);
    
    tbody.innerHTML = pageData.map(player => `
        <tr>
            <td>${player.identifier || '-'}</td>
            <td>${player.name || '-'}</td>
            <td>${player.icName || '-'}</td>
            <td>$${formatNumber(player.cash || 0)}</td>
            <td>$${formatNumber(player.bank || 0)}</td>
            <td>${player.job || '-'}</td>
        </tr>
    `).join('');
    
    updatePagination(filtered.length);
}

function sortTable(columnIndex) {
    if (currentSortColumn === columnIndex) {
        sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
        currentSortColumn = columnIndex;
        sortDirection = 'asc';
    }
    
    allPlayersData.sort((a, b) => {
        let aVal, bVal;
        switch(columnIndex) {
            case 0: aVal = a.identifier || ''; bVal = b.identifier || ''; break;
            case 1: aVal = a.name || ''; bVal = b.name || ''; break;
            case 2: aVal = a.icName || ''; bVal = b.icName || ''; break;
            case 3: aVal = a.cash || 0; bVal = b.cash || 0; break;
            case 4: aVal = a.bank || 0; bVal = b.bank || 0; break;
            case 5: aVal = a.job || ''; bVal = b.job || ''; break;
        }
        
        if (typeof aVal === 'number') {
            return sortDirection === 'asc' ? aVal - bVal : bVal - aVal;
        }
        return sortDirection === 'asc' ? aVal.localeCompare(bVal) : bVal.localeCompare(aVal);
    });
    
    displayPlayersTable();
}

function updatePagination(totalItems = allPlayersData.length) {
    const totalPages = Math.ceil(totalItems / entriesPerPage);
    const pagination = document.getElementById('table-pagination');
    
    if (totalPages <= 1) {
        pagination.innerHTML = '';
        return;
    }
    
    let html = '';
    if (currentPage > 1) {
        html += `<button onclick="goToPage(${currentPage - 1})">Previous</button>`;
    }
    
    for (let i = 1; i <= totalPages; i++) {
        if (i === 1 || i === totalPages || (i >= currentPage - 2 && i <= currentPage + 2)) {
            html += `<button class="${i === currentPage ? 'active' : ''}" onclick="goToPage(${i})">${i}</button>`;
        } else if (i === currentPage - 3 || i === currentPage + 3) {
            html += `<span>...</span>`;
        }
    }
    
    if (currentPage < totalPages) {
        html += `<button onclick="goToPage(${currentPage + 1})">Next</button>`;
    }
    
    pagination.innerHTML = html;
}

function goToPage(page) {
    currentPage = page;
    displayPlayersTable();
}

// ========== ACTIVITY DASHBOARD FUNCTIONS ==========

function loadActivity() {
    const date = document.getElementById('activity-date').value || new Date().toISOString().split('T')[0];
    fetch(`https://${GetParentResourceName()}/getActivity`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({date: date})
    }).catch(err => console.error('Error:', err));
}

function handleGetActivityResponse(data) {
    if (data.success) {
        displayActivity(data.activity);
    }
}

function displayActivity(activity) {
    const container = document.getElementById('activity-container');
    if (!activity || activity.length === 0) {
        container.innerHTML = '<div class="loading">No activity logs found for this date</div>';
        return;
    }
    
    container.innerHTML = activity.map(log => `
        <div class="activity-item">
            <div class="activity-time">${log.time || '-'}</div>
            <div class="activity-type ${log.type || 'info'}">${log.type || 'Info'}</div>
            <div class="activity-description">${log.description || '-'}</div>
            <div class="activity-player">${log.player || '-'}</div>
        </div>
    `).join('');
}

// ========== INVENTORY DASHBOARD FUNCTIONS ==========

function searchPlayerInventory() {
    const searchTerm = document.getElementById('inventory-search').value.trim();
    if (!searchTerm) {
        showNotification('Please enter a search term', true);
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/getPlayerInventory`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({identifier: searchTerm})
    }).catch(err => {
        showNotification('Error searching player', true);
        console.error('Error:', err);
    });
}

function handleGetPlayerInventoryResponse(data) {
    if (data.success) {
        // Store identifier for future operations
        window.currentInventoryIdentifier = data.identifier;
        displayPlayerInventory(data.inventory, data.identifier);
    } else {
        showNotification('Error: ' + (data.error || 'Player not found'), true);
        document.getElementById('inventory-details').style.display = 'none';
        window.currentInventoryIdentifier = null;
    }
}

function displayPlayerInventory(inventory, identifier) {
    const details = document.getElementById('inventory-details');
    details.style.display = 'block';
    
    // Player name and identifiers
    document.getElementById('inventory-player-name').textContent = 
        `${inventory.icInfo?.firstname || ''} ${inventory.icInfo?.lastname || 'Unknown'}`;
    document.getElementById('inventory-citizenid').textContent = identifier;
    document.getElementById('inventory-identifier').textContent = identifier;
    
    // Financial info
    document.getElementById('inventory-cash').textContent = '$' + formatNumber(inventory.money?.cash || 0);
    document.getElementById('inventory-bank').textContent = '$' + formatNumber(inventory.money?.bank || 0);
    
    // IC Information
    const icGrid = document.getElementById('ic-info-grid');
    icGrid.innerHTML = `
        <div class="info-card"><span class="label">First Name:</span><span>${inventory.icInfo?.firstname || '-'}</span></div>
        <div class="info-card"><span class="label">Last Name:</span><span>${inventory.icInfo?.lastname || '-'}</span></div>
        <div class="info-card"><span class="label">Date of Birth:</span><span>${inventory.icInfo?.dateofbirth || inventory.icInfo?.birthdate || '-'}</span></div>
        <div class="info-card"><span class="label">Gender:</span><span>${inventory.icInfo?.sex || (inventory.icInfo?.gender === 0 ? 'Male' : inventory.icInfo?.gender === 1 ? 'Female' : '-')}</span></div>
        <div class="info-card"><span class="label">Height:</span><span>${inventory.icInfo?.height || '-'}</span></div>
        <div class="info-card"><span class="label">Nationality:</span><span>${inventory.icInfo?.nationality || '-'}</span></div>
    `;
    
    // Job Information
    const jobGrid = document.getElementById('job-info-grid');
    jobGrid.innerHTML = `
        <div class="info-card"><span class="label">Job:</span><span>${inventory.job?.label || inventory.job?.name || 'Unemployed'}</span></div>
        <div class="info-card"><span class="label">Grade:</span><span>${inventory.job?.grade_label || inventory.job?.grade?.name || inventory.job?.grade || '-'}</span></div>
        <div class="info-card"><span class="label">Grade Level:</span><span>${inventory.job?.grade || inventory.job?.grade?.level || '-'}</span></div>
    `;
    
    // Inventory Items
    const itemsGrid = document.getElementById('items-grid');
    if (inventory.items && inventory.items.length > 0) {
        itemsGrid.innerHTML = inventory.items.map(item => {
            let metadataHtml = '';
            if (item.metadata) {
                const metaInfo = [];
                if (item.registered) metaInfo.push(`Registered: ${item.registered}`);
                if (item.ammo !== undefined) metaInfo.push(`Ammo: ${item.ammo}`);
                if (item.durability !== undefined) metaInfo.push(`Durability: ${Math.round(item.durability)}%`);
                if (item.serial) metaInfo.push(`Serial: ${item.serial}`);
                if (metaInfo.length > 0) {
                    metadataHtml = `<div class="item-metadata">${metaInfo.join(' | ')}</div>`;
                }
            }
            return `
                <div class="item-card">
                    <div class="item-header">
                        <div class="item-name">${item.label || item.name}</div>
                        <div class="item-slot">Slot: ${item.slot || '-'}</div>
                    </div>
                    <div class="item-count">Count: ${item.count || 0}</div>
                    ${metadataHtml}
                </div>
            `;
        }).join('');
    } else {
        itemsGrid.innerHTML = '<div class="loading">No items found</div>';
    }
    
    // Store current identifier for inventory operations
    window.currentInventoryIdentifier = identifier;
    
    // Set job edit fields
    document.getElementById('edit-job-name').value = inventory.job?.name || '';
    document.getElementById('edit-job-grade').value = inventory.job?.grade || 0;
}

function changePlayerJob() {
    if (!window.currentInventoryIdentifier) {
        showNotification('No player selected', true);
        return;
    }
    
    const jobName = document.getElementById('edit-job-name').value.trim();
    const grade = parseInt(document.getElementById('edit-job-grade').value);
    
    if (!jobName) {
        showNotification('Please enter a job name', true);
        return;
    }
    
    if (isNaN(grade) || grade < 0) {
        showNotification('Please enter a valid grade', true);
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/changePlayerJob`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            identifier: window.currentInventoryIdentifier,
            jobName: jobName,
            grade: grade
        })
    }).catch(err => {
        showNotification('Error changing job', true);
        console.error('Error:', err);
    });
}

function loadPlayerVehicles() {
    if (!window.currentInventoryIdentifier) {
        showNotification('No player selected', true);
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/getPlayerVehicles`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            identifier: window.currentInventoryIdentifier
        })
    }).catch(err => {
        showNotification('Error loading vehicles', true);
        console.error('Error:', err);
    });
}

function handleGetPlayerVehiclesResponse(data) {
    if (data.success) {
        displayVehicles(data.vehicles);
    } else {
        showNotification('Error: ' + (data.error || 'Failed to load vehicles'), true);
        document.getElementById('vehicles-grid').innerHTML = '<div class="loading">Error loading vehicles</div>';
    }
}

function displayVehicles(vehicles) {
    const vehiclesGrid = document.getElementById('vehicles-grid');
    if (!vehicles || vehicles.length === 0) {
        vehiclesGrid.innerHTML = '<div class="loading">No vehicles found</div>';
        return;
    }
    
    vehiclesGrid.innerHTML = vehicles.map(vehicle => `
        <div class="vehicle-card">
            <div class="vehicle-header">
                <div class="vehicle-model">${vehicle.model || 'Unknown'}</div>
                <div class="vehicle-plate">${vehicle.plate || '-'}</div>
            </div>
            <div class="vehicle-info">
                <div class="vehicle-info-item">
                    <span class="label">Status:</span>
                    <span class="value ${vehicle.stored == 1 ? 'stored' : 'out'}">${vehicle.stored == 1 ? 'Stored' : 'Out'}</span>
                </div>
                <div class="vehicle-info-item">
                    <span class="label">Garage:</span>
                    <span class="value">${vehicle.garage || 'Unknown'}</span>
                </div>
            </div>
        </div>
    `).join('');
}

function handleChangePlayerJobResponse(data) {
    if (data.success) {
        showNotification(data.message || 'Job updated successfully');
        // Reload inventory to refresh job info
        if (window.currentInventoryIdentifier) {
            searchPlayerInventory();
        }
    } else {
        showNotification('Error: ' + (data.error || 'Failed to update job'), true);
    }
}

