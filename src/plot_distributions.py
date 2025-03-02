import matplotlib.pyplot as plt
import seaborn as sns

def plot_histograms(df, num_cols, bins=30):
    """Plots histograms for numerical columns in the dataset."""
    plt.figure(figsize=(12, 8))
    df[num_cols].hist(bins=bins, figsize=(12, 8), layout=(3, 2), color='skyblue', edgecolor='black')
    plt.suptitle("Histograms of Numerical Features")
    plt.show()

def plot_boxplots(df, num_cols):
    """Plots box plots for numerical columns in the dataset."""
    plt.figure(figsize=(12, 8))
    for i, col in enumerate(num_cols, 1):
        plt.subplot(3, 2, i)
        sns.boxplot(x=df[col], color='lightblue')
        plt.title(f'Box Plot of {col}')
    plt.tight_layout()
    plt.show()
