import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cluster import AgglomerativeClustering
from scipy.cluster.hierarchy import dendrogram, linkage
from sklearn.metrics import accuracy_score, recall_score, confusion_matrix

columnas=["id","pos_x","pos_y","iter","clasificacion"]
df=pd.read_csv("resultados (1).csv",names=columnas,skiprows=1)
xent=df[["pos_x","iter"]]
y=df["clasificacion"];
scaler=StandardScaler()
x_scaled=scaler.fit_transform(xent)
x_train,x_test,y_train,y_test=train_test_split(x_scaled,y,test_size=0.3,random_state=42)

kmeans=KMeans(
    n_clusters=2,
    init='k-means++',
    n_init=10,
    max_iter=300,
    tol=1e-4,
    random_state=42
)
y_pred_km=kmeans.fit_predict(x_scaled)

# Crear una figura con dos subgráficos (uno al lado del otro)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Gráfico 1: Original
sns.scatterplot(data=df, x='pos_x', y='pos_y', hue='clasificacion', palette='viridis', ax=ax1)
ax1.set_title('Clasificación Original (Real)')

# Gráfico 2: Clasificación de K-Means
# x_scaled para las coordenadas (pos_x es columna 1, iter es columna 2)
sns.scatterplot(x=x_scaled[:, 0], y=x_scaled[:, 1], hue=y_pred_km, palette='magma', ax=ax2)
ax2.set_title('Agrupamiento por K-Means')

plt.show()

# 1. Obtener las etiquetas reales y las predicciones
y_true = df["clasificacion"]
y_pred = y_pred_km

# 2. Calcular Accuracy y Recall inicial
acc = accuracy_score(y_true, y_pred)
rec = recall_score(y_true, y_pred)

# 3. Se checa el accuracy, si es muy bajo (menor a 0.5), 
# es probable que K-Means haya invertido las etiquetas (0 por 1 y viceversa)
if acc < 0.5:
    y_pred_corregido = [1 if p == 0 else 0 for p in y_pred]
    acc = accuracy_score(y_true, y_pred_corregido)
    rec = recall_score(y_true, y_pred_corregido)
    print("Nota: Se invirtieron las etiquetas de K-Means para coincidir con las reales.")

print(f"Accuracy: {acc:.2f}")
print(f"Recall: {rec:.2f}")

# 2. Implementación del Método Jerárquico
# ward: minimiza la varianza de los clusters que se van uniendo
jerarquico = AgglomerativeClustering(n_clusters=2, linkage='ward')
y_pred_jer = jerarquico.fit_predict(x_scaled)

# 3. Crear el Dendrograma
# Linkage calcula las distancias jerárquicas
Z = linkage(x_scaled, method='ward')

plt.figure(figsize=(12, 5))
dendrogram(Z, truncate_mode='lastp', p=30) # Mostramos los últimos 30 nodos para que sea legible
plt.title('Dendrograma de Similitud Celular')
plt.xlabel('Índice de la Célula (o tamaño del grupo)')
plt.ylabel('Distancia (Disimilitud)')
plt.show()

# 4. Evaluación y Corrección de Etiquetas
y_pred = y_pred_jer
acc = accuracy_score(y_true, y_pred)

if acc < 0.5:
    y_pred = [1 if p == 0 else 0 for p in y_pred]
    acc = accuracy_score(y_true, y_pred)

rec = recall_score(y_true, y_pred)

print(f"--- Resultados Jerárquico ---")
print(f"Accuracy: {acc:.2f}")
print(f"Recall: {rec:.2f}")
