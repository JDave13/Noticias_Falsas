# 📰 Detección de Noticias Falsas con NLP

[![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![scikit-learn](https://img.shields.io/badge/scikit--learn-ML-F7931E?logo=scikitlearn&logoColor=white)](https://scikit-learn.org/)
[![NLTK](https://img.shields.io/badge/NLTK-NLP-green)](https://www.nltk.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-completo-brightgreen)]()

Pipeline completo de **Procesamiento de Lenguaje Natural** para clasificar noticias en español como **verdaderas o falsas**, construido de punta a punta: recolección propia de datos (web scraping), consolidación de corpus, preprocesamiento lingüístico, extracción de características Bag-of-Words, ponderación TF-IDF/TO y evaluación comparativa de 4 algoritmos de aprendizaje supervisado sobre 32 configuraciones experimentales.

Proyecto académico de la asignatura **Procesamiento de Lenguaje Natural** (Universidad Nacional de Colombia), desarrollado en equipo. El resultado es un pipeline reproducible con métricas verificadas y un modelo final que alcanza **F1-Score = 0.8846**.

> 📄 Informe técnico completo: [`informe_practica1.md`](informe_practica1.md) · 📊 Versión Word: [`out/Informe_Practica1_NoticiasFalsas.docx`](out/Informe_Practica1_NoticiasFalsas.docx)

---

## 🎯 ¿Qué resuelve este proyecto?

Dado el texto de una noticia en español, predecir si es **verdadera** o **falsa**, comparando enfoques clásicos de NLP (sin deep learning) para entender qué combinaciones de representación de texto y algoritmo funcionan mejor en este dominio — incluyendo un hallazgo contraintuitivo sobre TF-IDF vs. conteos simples de términos (ver [Resultados](#-resultados-y-métricas)).

## 🧠 Stack tecnológico

| Categoría | Herramientas |
|---|---|
| Lenguaje | Python 3.x |
| Recolección de datos | `requests`, `BeautifulSoup4`, `Selenium` + `webdriver-manager` |
| Procesamiento de datos | `pandas`, `numpy` |
| NLP | `NLTK` (stopwords, tokenización, `SnowballStemmer` en español) |
| Machine Learning | `scikit-learn` (`CountVectorizer`, `TfidfTransformer`, `LogisticRegression`, `DecisionTreeClassifier`, `KNeighborsClassifier`, `SVC`), `scipy.sparse` |
| Visualización | `matplotlib`, `seaborn` |
| Entorno | `Jupyter Notebook` |
| Reportería | Markdown → Word vía `pandoc` |
| Automatización | Tareas de VS Code (`tasks.json`), scripts de PowerShell |

## 🔬 Pipeline del proyecto

```
1. Creación de corpus       → Web scraping propio (4 fuentes) + dataset existente en español
2. Preprocesamiento         → Minúsculas, sin tildes/URLs/HTML/números/puntuación
3. Extracción de features   → Bag-of-Words (uni + bigramas), stopwords, stemming, min_df=3
4. Ponderación               → Term Occurrences (TO) vs. TF-IDF
5. Modelado y validación    → 4 algoritmos × 8 configuraciones, CV k=10, split 80/20
6. Resultados                → Tablas, figuras y reporte final en Word
```

Cada etapa vive en su propio notebook dentro de [`corpus/`](corpus/), numerado en orden de ejecución, y produce artefactos versionados (matrices `.npz`, vocabularios `.json`) que alimentan la siguiente etapa.

## 📊 Resultados y métricas

**Corpus:** 7,200 documentos perfectamente balanceados (3,600 verdaderos / 3,600 falsos), combinando 200 documentos de web scraping propio (4 contribuidores) y 7,000 muestreados de un dataset español existente de más de 57,000 registros.

**Experimento:** 4 algoritmos (Regresión Logística, Árboles de Decisión, K-NN, SVM) evaluados sobre 8 configuraciones de features (TO/TF-IDF × ninguna/stopwords/stemming/ambas) = **32 combinaciones**, con validación cruzada `k=10` y partición `train/test` 80/20 estratificada (`random_state=42`).

### 🏆 Mejor configuración

| Algoritmo | Ponderación | Reducción | F1-Score | Precision | Recall |
|---|---|---|---|---|---|
| **Regresión Logística** | **TO** | **Ninguna** | **0.8846** | **0.8866** | **0.8847** |

### Top 5 configuraciones

| # | Algoritmo | Ponderación | Reducción | F1-Score |
|---|---|---|---|---|
| 1 | Regresión Logística | TO | Ninguna | 0.8846 |
| 2 | Árboles de Decisión | TO | Stopwords | 0.8812 |
| 3 | Regresión Logística | TO | Stopwords | 0.8783 |
| 4 | Regresión Logística | TF-IDF | Stopwords | 0.8729 |
| 5 | Regresión Logística | TO | Ambas | 0.8721 |

### F1-Score máximo por algoritmo

![F1-Score Máximo por Algoritmo](figures/f1_max_por_algoritmo.png)

### F1-Score medio por ponderación y algoritmo

![F1-Score Medio por Ponderación y Algoritmo](figures/f1_medio_por_ponderacion_y_algoritmo.png)

### F1-Score medio por técnica de reducción y algoritmo

![F1-Score Medio por Reducción y Algoritmo](figures/f1_medio_por_reduccion_y_algoritmo.png)

### 💡 Hallazgos clave

- **Regresión Logística y Árboles de Decisión dominan** (F1 ≈ 0.88), muy por encima de K-NN (F1 máx. 0.7851), afectado por la maldición de la dimensionalidad en un espacio de features disperso y de alta dimensión.
- **Hallazgo contraintuitivo:** en 3 de 4 algoritmos (LR, DT, SVM), los conteos directos de términos (**TO**) superan a **TF-IDF**. Solo K-NN se beneficia de la normalización TF-IDF. Esto sugiere que, para este corpus, la frecuencia absoluta de ciertos términos es más discriminativa que su rareza relativa.
- **El preprocesamiento agresivo no siempre ayuda:** para Regresión Logística, la mejor configuración es *sin* stopwords ni stemming — preservar el texto completo conserva señal útil para el modelo lineal.
- Todas las métricas de esta sección fueron **extraídas y verificadas directamente de la salida real del notebook de modelado** (`corpus/5_tecnicas_aprendizaje/5_tecnicas.ipynb`), no simuladas.

Más detalle y análisis por algoritmo en el [informe técnico completo](informe_practica1.md).

## 📁 Estructura del repositorio

```
corpus/
├── 1_creacion_corpus/        # Consolidación del corpus (scraping + dataset externo)
├── 2_preprocesamiento/       # Normalización y limpieza de texto
├── 3_caracteristicas_bow/    # Extracción Bag-of-Words (matrices .npz, vocabularios .json)
├── 4_ponderacion/            # Ponderación TF-IDF
├── 5_tecnicas_aprendizaje/   # Entrenamiento y evaluación de los 4 modelos
├── web_scraping/             # Scripts de scraping por contribuidor (David, Jessi, Jonatan, Josué)
├── fuente_1/                 # Corpus propio en texto plano (falsas/verdaderas)
└── fuente_2/                 # Dataset externo en español
results/                      # Tablas y métricas generadas (CSV, JSON, TXT)
figures/                      # Gráficas del análisis (PNG)
out/                          # Informe final exportado a Word
scripts/                      # Utilidades de exportación (PowerShell)
generate_figures.py           # Genera las 3 figuras del análisis
extract_metrics.py            # Genera tablas resumen desde los resultados
informe_practica1.md          # Informe técnico completo
```

## ⚙️ Requisitos

- Python 3.x con `pandas`, `numpy`, `scikit-learn`, `nltk`, `matplotlib`, `seaborn`, `jupyter`, `scipy`
- `pandoc` para exportar el informe a Word (`winget install --id JohnMacFarlane.Pandoc -e --source winget`)

```powershell
pip install pandas numpy scikit-learn nltk matplotlib seaborn jupyter scipy
```

## ▶️ Cómo reproducirlo

**1. Ejecutar el pipeline de notebooks en orden:**

```
corpus/1_creacion_corpus/1_creacion_corpus.ipynb
corpus/2_preprocesamiento/2_preprocesamiento.ipynb
corpus/3_caracteristicas_bow/3_extraccion_caracteristicas.ipynb
corpus/4_ponderacion/p_caracteristicas.ipynb
corpus/5_tecnicas_aprendizaje/5_tecnicas.ipynb
```

**2. Generar figuras y métricas:**

```powershell
python generate_figures.py
python extract_metrics.py
```

**3. Exportar el informe a Word:**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/make_docx.ps1
```

También disponible como tareas de VS Code (`Ctrl+Shift+P` → `Tasks: Run Task`): `Build Word Report`, `Generate Figures`, `Run Full Pipeline`, `Open Output Directory`, `Clean Output`. Ver [`COMANDOS_RAPIDOS.md`](COMANDOS_RAPIDOS.md) para la referencia completa de comandos.

**Reproducibilidad:** todas las ejecuciones usan `random_state=42`. Si cambian los datos o el código de modelado, hay que regenerar `results/`, `figures/` y `out/` para mantenerlos sincronizados con el informe.

## 🧩 Metodología resumida

- **Preprocesamiento:** minúsculas, eliminación de tildes, URLs, HTML, números, puntuación y emoticones.
- **Features:** `CountVectorizer` con unigramas + bigramas, `min_df=3`, stopwords en español (NLTK) y stemming (`SnowballStemmer`).
- **Ponderación:** Term Occurrences (conteos directos) vs. TF-IDF (`TfidfTransformer`, `norm='l2'`).
- **Modelos:** `LogisticRegression`, `DecisionTreeClassifier`, `KNeighborsClassifier`, `SVC` — todos con `random_state=42` donde aplica.
- **Validación:** split 80/20 estratificado + validación cruzada `k=10` (`scoring='f1_weighted'`).

## 👥 Contribuyentes

- David
- Jessi
- Jonatan
- Josué

## 📄 Licencia

Proyecto académico de la asignatura Procesamiento de Lenguaje Natural (Universidad Nacional de Colombia), publicado bajo licencia MIT para facilitar su consulta y reutilización. Ver [`LICENSE`](LICENSE).
