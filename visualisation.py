from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

path = Path('.')
for file in path.iterdir():
    if file.name.endswith('.txt'):
        name = file.stem
        df = pd.read_csv(file, sep=' ', header=None, names=['X', 'Y'], skiprows=0)
        fig, ax = plt.subplots()
        sns.lineplot(x=df['X'], y=df['Y'], ax=ax)
        ax.set_xlim(0)
        ax.set_ylim(1)
        plt.savefig(f'{name}.png', dpi=300, bbox_inches='tight')
        plt.close()
