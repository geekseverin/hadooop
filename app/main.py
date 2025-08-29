from flask import Flask, render_template, jsonify
import pandas as pd
import json
import os
import glob
from pymongo import MongoClient
import plotly.graph_objs as go
import plotly.utils

app = Flask(__name__)

def read_hdfs_output(pattern):
    """Lecture des fichiers de sortie HDFS"""
    try:
        files = glob.glob(f'/app/data/{pattern}*/part-*')
        if files:
            df = pd.read_csv(files[0])
            return df
        return pd.DataFrame()
    except Exception as e:
        print(f"Erreur lecture HDFS: {e}")
        return pd.DataFrame()

def read_pig_output(output_dir):
    """Lecture des sorties Pig"""
    try:
        files = glob.glob(f'/app/data/{output_dir}/part-*')
        if files:
            df = pd.read_csv(files[0], header=None)
            return df
        return pd.DataFrame()
    except Exception as e:
        print(f"Erreur lecture Pig: {e}")
        return pd.DataFrame()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

@app.route('/api/city-analysis')
def city_analysis():
    """API pour l'analyse par ville"""
    try:
        # Essayer de lire depuis Spark d'abord
        df = read_hdfs_output('spark_city_analysis')
        
        if df.empty:
            # Fallback vers Pig
            df = read_pig_output('city_analysis')
            if not df.empty and len(df.columns) >= 4:
                df.columns = ['city', 'employee_count', 'avg_salary', 'max_salary', 'min_salary']
        
        if not df.empty:
            # Création du graphique
            fig = go.Figure()
            
            fig.add_trace(go.Bar(
                x=df['city'] if 'city' in df.columns else df.iloc[:, 0],
                y=df['employee_count'] if 'employee_count' in df.columns else df.iloc[:, 1],
                name='Nombre d\'employés',
                yaxis='y'
            ))
            
            fig.add_trace(go.Scatter(
                x=df['city'] if 'city' in df.columns else df.iloc[:, 0],
                y=df['avg_salary'] if 'avg_salary' in df.columns else df.iloc[:, 2],
                mode='lines+markers',
                name='Salaire moyen',
                yaxis='y2'
            ))
            
            fig.update_layout(
                title='Analyse par Ville',
                xaxis_title='Ville',
                yaxis=dict(title='Nombre d\'employés', side='left'),
                yaxis2=dict(title='Salaire moyen', side='right', overlaying='y'),
                hovermode='x unified'
            )
            
            graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
            return jsonify({'graph': graphJSON, 'data': df.to_dict('records')})
        
        return jsonify({'error': 'Aucune donnée disponible'})
    
    except Exception as e:
        return jsonify({'error': f'Erreur: {str(e)}'})

@app.route('/api/sales-analysis')
def sales_analysis():
    """API pour l'analyse des ventes"""
    try:
        # Essayer de lire depuis Spark
        df = read_hdfs_output('spark_region_analysis')
        
        if df.empty:
            # Fallback vers Pig
            df = read_pig_output('region_analysis')
            if not df.empty and len(df.columns) >= 3:
                df.columns = ['region', 'product_count', 'total_revenue', 'avg_revenue']
        
        if not df.empty:
            # Création du graphique en camembert
            fig = go.Figure(data=[go.Pie(
                labels=df['region'] if 'region' in df.columns else df.iloc[:, 0],
                values=df['total_revenue'] if 'total_revenue' in df.columns else df.iloc[:, 2],
                title='Répartition du CA par région'
            )])
            
            fig.update_layout(title='Analyse des Ventes par Région')
            
            graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
            return jsonify({'graph': graphJSON, 'data': df.to_dict('records')})
        
        return jsonify({'error': 'Aucune donnée de vente disponible'})
    
    except Exception as e:
        return jsonify({'error': f'Erreur: {str(e)}'})

@app.route('/api/top-products')
def top_products():
    """API pour les top produits"""
    try:
        df = read_hdfs_output('spark_top_products')
        
        if df.empty:
            df = read_pig_output('top_products')
            if not df.empty:
                df.columns = ['product_id', 'product_name', 'category', 'price', 'quantity', 'revenue', 'region']
        
        if not df.empty:
            # Top 10 produits
            top_10 = df.head(10) if len(df) > 10 else df
            
            fig = go.Figure(data=[go.Bar(
                x=top_10['product_name'] if 'product_name' in top_10.columns else top_10.iloc[:, 1],
                y=top_10['revenue'] if 'revenue' in top_10.columns else top_10.iloc[:, 5],
                text=top_10['revenue'] if 'revenue' in top_10.columns else top_10.iloc[:, 5],
                textposition='auto'
            )])
            
            fig.update_layout(
                title='Top 10 des Produits par Chiffre d\'Affaires',
                xaxis_title='Produit',
                yaxis_title='Chiffre d\'Affaires'
            )
            
            graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
            return jsonify({'graph': graphJSON, 'data': top_10.to_dict('records')})
        
        return jsonify({'error': 'Aucune donnée produit disponible'})
    
    except Exception as e:
        return jsonify({'error': f'Erreur: {str(e)}'})

@app.route('/api/mongodb-data')
def mongodb_data():
    """API pour les données MongoDB"""
    try:
        client = MongoClient('mongodb://admin:password@mongodb:27017/?authSource=admin')
        db = client.bigdata
        
        employees = list(db.employees.find({}, {'_id': 0}))
        
        if employees:
            df = pd.DataFrame(employees)
            
            # Analyse simple
            city_stats = df.groupby('city').agg({
                'salary': ['mean', 'count']
            }).round(2)
            
            city_stats.columns = ['avg_salary', 'employee_count']
            city_stats = city_stats.reset_index()
            
            fig = go.Figure(data=[go.Bar(
                x=city_stats['city'],
                y=city_stats['employee_count'],
                name='Employés MongoDB'
            )])
            
            fig.update_layout(title='Données depuis MongoDB')
            
            graphJSON = json.dumps(fig, cls=plotly.utils.PlotlyJSONEncoder)
            return jsonify({'graph': graphJSON, 'data': city_stats.to_dict('records')})
        
        return jsonify({'error': 'Aucune donnée MongoDB'})
    
    except Exception as e:
        return jsonify({'error': f'Erreur MongoDB: {str(e)}'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)