#!/usr/bin/env python3
"""
Script para extraer métricas detalladas desde el notebook de resultados.
Este script lee directamente los resultados del notebook 5_tecnicas.ipynb
y genera tablas CSV con las métricas completas.
"""

import pandas as pd
import numpy as np
from pathlib import Path
import json

def extract_metrics_from_notebook():
    """
    Extrae métricas del notebook de técnicas de aprendizaje.
    Requiere que el notebook haya sido ejecutado previamente.
    """
    try:
        # Cargar datos desde el JSON de resumen
        with open('results/resumen_resultados.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Convertir a DataFrame
        df_results = pd.DataFrame(data['resultados'])
        
        # Expandir métricas
        results_expanded = []
        for _, row in df_results.iterrows():
            results_expanded.append({
                'Algoritmo': row['algoritmo'],
                'Ponderación': row['ponderacion'], 
                'Reducción': row['reduccion'],
                'Accuracy': row['accuracy'],
                'Precision': row['precision'],
                'Recall': row['recall'],
                'F1-Score': row['f1']
            })
        
        df_final = pd.DataFrame(results_expanded)
        
        # Guardar tabla completa
        df_final.to_csv('results/metricas_completas.csv', index=False, encoding='utf-8')
        print("Tabla de metricas guardada: results/metricas_completas.csv")
        
        # Crear tabla pivot por algoritmo
        pivot_algo = df_final.pivot_table(
            index=['Algoritmo'],
            columns=['Ponderación', 'Reducción'],
            values='F1-Score'
        )
        pivot_algo.to_csv('results/f1_pivot_algoritmos.csv', encoding='utf-8')
        print("Tabla pivot por algoritmo: results/f1_pivot_algoritmos.csv")
        
        # Estadísticas por ponderación
        pond_stats = df_final.groupby(['Ponderación', 'Algoritmo'])['F1-Score'].agg([
            'mean', 'std', 'min', 'max'
        ]).round(4)
        pond_stats.to_csv('results/stats_ponderacion.csv', encoding='utf-8')
        print("Estadisticas por ponderacion: results/stats_ponderacion.csv")
        
        # Top configuraciones
        top_configs = df_final.nlargest(10, 'F1-Score')[
            ['Algoritmo', 'Ponderación', 'Reducción', 'F1-Score']
        ]
        top_configs.to_csv('results/top_configuraciones.csv', index=False, encoding='utf-8')
        print("Top configuraciones: results/top_configuraciones.csv")
        
        return df_final
        
    except Exception as e:
        print(f"Error extrayendo metricas: {e}")
        return None

def generate_summary_report(df_results):
    """Generar reporte resumen en texto"""
    if df_results is None:
        return
        
    report = []
    report.append("# REPORTE RESUMEN - DETECCION NOTICIAS FALSAS")
    report.append("=" * 50)
    report.append("")
    
    # Mejor configuración
    best = df_results.loc[df_results['F1-Score'].idxmax()]
    report.append("## MEJOR CONFIGURACION")
    report.append(f"Algoritmo: {best['Algoritmo']}")
    report.append(f"Ponderación: {best['Ponderación']}")
    report.append(f"Reducción: {best['Reducción']}")
    report.append(f"F1-Score: {best['F1-Score']:.4f}")
    report.append("")
    
    # Top 5
    report.append("## TOP 5 CONFIGURACIONES")
    top_5 = df_results.nlargest(5, 'F1-Score')
    for i, (_, row) in enumerate(top_5.iterrows(), 1):
        report.append(f"{i}. {row['Algoritmo']} + {row['Ponderación']} + {row['Reducción']}: {row['F1-Score']:.4f}")
    report.append("")
    
    # Estadísticas por algoritmo
    report.append("## RENDIMIENTO POR ALGORITMO")
    algo_stats = df_results.groupby('Algoritmo')['F1-Score'].agg(['mean', 'max', 'min'])
    for algo in algo_stats.index:
        stats = algo_stats.loc[algo]
        report.append(f"{algo}: mu={stats['mean']:.4f}, max={stats['max']:.4f}, min={stats['min']:.4f}")
    report.append("")
    
    # Comparación ponderaciones
    report.append("## COMPARACION PONDERACIONES")
    pond_comparison = df_results.groupby('Ponderación')['F1-Score'].agg(['mean', 'std'])
    for pond in pond_comparison.index:
        stats = pond_comparison.loc[pond]
        report.append(f"{pond}: mu={stats['mean']:.4f} +/-{stats['std']:.4f}")
    report.append("")
    
    # Guardar reporte
    with open('results/reporte_resumen.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(report))
    
    print("Reporte resumen: results/reporte_resumen.txt")

def main():
    print("EXTRACTOR DE METRICAS - NOTICIAS FALSAS")
    print("=" * 45)
    
    # Crear directorio results si no existe
    Path("results").mkdir(exist_ok=True)
    
    # Extraer métricas
    df_results = extract_metrics_from_notebook()
    
    if df_results is not None:
        # Generar reporte resumen
        generate_summary_report(df_results)
        
        print("\nEXTRACCION COMPLETADA")
        print("Archivos generados en results/:")
        print("   - metricas_completas.csv")
        print("   - f1_pivot_algoritmos.csv") 
        print("   - stats_ponderacion.csv")
        print("   - top_configuraciones.csv")
        print("   - reporte_resumen.txt")
    else:
        print("No se pudieron extraer las metricas")

if __name__ == "__main__":
    main()
