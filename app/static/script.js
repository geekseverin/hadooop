// Fonction utilitaire pour créer une table HTML
function createTable(data, containerId) {
    if (!data || data.length === 0) {
        document.getElementById(containerId).innerHTML = '<div class="error">Aucune donnée disponible</div>';
        return;
    }
    
    const headers = Object.keys(data[0]);
    let tableHTML = '<table><thead><tr>';
    
    headers.forEach(header => {
        tableHTML += `<th>${header}</th>`;
    });
    tableHTML += '</tr></thead><tbody>';
    
    data.forEach(row => {
        tableHTML += '<tr>';
        headers.forEach(header => {
            let value = row[header];
            // Formatage des nombres
            if (typeof value === 'number') {
                value = value.toLocaleString('fr-FR', {
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 2
                });
            }
            tableHTML += `<td>${value}</td>`;
        });
        tableHTML += '</tr>';
    });
    
    tableHTML += '</tbody></table>';
    document.getElementById(containerId).innerHTML = tableHTML;
}

// Fonction pour afficher les erreurs
function showError(containerId, message) {
    document.getElementById(containerId).innerHTML = `<div class="error">${message}</div>`;
}

// Chargement de l'analyse par ville
async function loadCityAnalysis() {
    try {
        const response = await fetch('/api/city-analysis');
        const result = await response.json();
        
        if (result.error) {
            showError('city-analysis', result.error);
            showError('city-table', result.error);
        } else {
            // Affichage du graphique
            const graph = JSON.parse(result.graph);
            Plotly.newPlot('city-analysis', graph.data, graph.layout, {responsive: true});
            
            // Affichage du tableau
            createTable(result.data, 'city-table');
        }
    } catch (error) {
        showError('city-analysis', 'Erreur de chargement des données');
        showError('city-table', 'Erreur de chargement des données');
        console.error('Erreur:', error);
    }
}

// Chargement de l'analyse des ventes
async function loadSalesAnalysis() {
    try {
        const response = await fetch('/api/sales-analysis');
        const result = await response.json();
        
        if (result.error) {
            showError('sales-analysis', result.error);
            showError('sales-table', result.error);
        } else {
            // Affichage du graphique
            const graph = JSON.parse(result.graph);
            Plotly.newPlot('sales-analysis', graph.data, graph.layout, {responsive: true});
            
            // Affichage du tableau
            createTable(result.data, 'sales-table');
        }
    } catch (error) {
        showError('sales-analysis', 'Erreur de chargement des données');
        showError('sales-table', 'Erreur de chargement des données');
        console.error('Erreur:', error);
    }
}

// Chargement du top produits
async function loadTopProducts() {
    try {
        const response = await fetch('/api/top-products');
        const result = await response.json();
        
        if (result.error) {
            showError('top-products', result.error);
            showError('products-table', result.error);
        } else {
            // Affichage du graphique
            const graph = JSON.parse(result.graph);
            Plotly.newPlot('top-products', graph.data, graph.layout, {responsive: true});
            
            // Affichage du tableau
            createTable(result.data, 'products-table');
        }
    } catch (error) {
        showError('top-products', 'Erreur de chargement des données');
        showError('products-table', 'Erreur de chargement des données');
        console.error('Erreur:', error);
    }
}

// Chargement des données MongoDB
async function loadMongoDBAnalysis() {
    try {
        const response = await fetch('/api/mongodb-data');
        const result = await response.json();
        
        if (result.error) {
            showError('mongodb-analysis', result.error);
            showError('mongodb-table', result.error);
        } else {
            // Affichage du graphique
            const graph = JSON.parse(result.graph);
            Plotly.newPlot('mongodb-analysis', graph.data, graph.layout, {responsive: true});
            
            // Affichage du tableau
            createTable(result.data, 'mongodb-table');
        }
    } catch (error) {
        showError('mongodb-analysis', 'Erreur de chargement des données');
        showError('mongodb-table', 'Erreur de chargement des données');
        console.error('Erreur:', error);
    }
}

// Chargement automatique au démarrage de la page
document.addEventListener('DOMContentLoaded', function() {
    // Vérifier si nous sommes sur la page dashboard
    if (window.location.pathname === '/dashboard') {
        console.log('Chargement du dashboard...');
        
        // Délai pour permettre le chargement complet
        setTimeout(() => {
            loadCityAnalysis();
            loadSalesAnalysis();
            loadTopProducts();
            loadMongoDBAnalysis();
        }, 1000);
    }
});

// Actualisation périodique des données (toutes les 30 secondes)
setInterval(() => {
    if (window.location.pathname === '/dashboard') {
        loadCityAnalysis();
        loadSalesAnalysis();
        loadTopProducts();
        loadMongoDBAnalysis();
    }
}, 30000);