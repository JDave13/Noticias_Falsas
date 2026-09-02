# Comandos rápidos

Referencia breve para generar artefactos, revisar resultados y exportar el informe.

## Informe y figuras

```powershell
python generate_figures.py
python extract_metrics.py
powershell -ExecutionPolicy Bypass -File scripts/make_docx.ps1
```

## Pipeline completo

```powershell
python generate_figures.py
python extract_metrics.py
powershell -ExecutionPolicy Bypass -File scripts/make_docx.ps1
```

## Tareas de VS Code

Desde `Ctrl+Shift+P` y luego `Tasks: Run Task`:

- `Build Word Report`: exporta `informe_practica1.md` a `out/Informe_Practica1_NoticiasFalsas.docx`.
- `Generate Figures`: crea las tres figuras del análisis.
- `Run Full Pipeline`: ejecuta figuras y exportación del informe.
- `Open Output Directory`: abre la carpeta `out/`.
- `Clean Output`: elimina los artefactos generados.

## Notebooks del pipeline

```powershell
jupyter notebook corpus/1_creacion_corpus/1_creacion_corpus.ipynb
jupyter notebook corpus/2_preprocesamiento/2_preprocesamiento.ipynb
jupyter notebook corpus/3_caracteristicas_bow/3_extraccion_caracteristicas.ipynb
jupyter notebook corpus/4_ponderacion/p_caracteristicas.ipynb
jupyter notebook corpus/5_tecnicas_aprendizaje/5_tecnicas.ipynb
```

## Limpieza de artefactos

```powershell
if (Test-Path figures) { Remove-Item figures -Recurse -Force }
if (Test-Path out) { Remove-Item out -Recurse -Force }
```

## Archivos generados

- `figures/f1_max_por_algoritmo.png`
- `figures/f1_medio_por_ponderacion_y_algoritmo.png`
- `figures/f1_medio_por_reduccion_y_algoritmo.png`
- `results/metricas_completas.csv`
- `results/f1_pivot_algoritmos.csv`
- `results/stats_ponderacion.csv`
- `results/top_configuraciones.csv`
- `results/reporte_resumen.txt`
- `out/Informe_Practica1_NoticiasFalsas.docx`

## Nota

El informe fuente es `informe_practica1.md`. Si cambian los resultados, vuelve a ejecutar el flujo completo para mantener sincronizados el texto, las tablas y las figuras.
