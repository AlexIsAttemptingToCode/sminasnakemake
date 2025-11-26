import sys
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable

if __name__ == "__main__":
    # Input clean_csv
    csv_file = sys.argv[1]
    plot_file = sys.argv[2]
    
    # Read data
    df = pd.read_csv(csv_file)
    
    # Plot detup
    plt.figure(figsize=(10, 7)) # Increased size slightly to fit labels
    sns.set_style("whitegrid")
    
    # Create scatter plot
    ax = sns.scatterplot(
        data=df, 
        x='RMSD_lb', 
        y='Affinity', 
        hue='Mode', 
        palette='coolwarm', 
        s=150,              
        edgecolor='black',
        legend=False
    )
    
    # Add labels to dots with iteration
    for i in range(df.shape[0]):
        plt.text(
            x=df.RMSD_lb[i] + 0.1,  # Shift x axis to the right
            y=df.Affinity[i],        
            s=str(df.Mode[i]),       # Add mode number
            fontdict=dict(color='black', size=10, weight='bold')
        )
    
    # Add colorbar for ranking
    norm = Normalize(vmin=df['Mode'].min(), vmax=df['Mode'].max())
    sm = ScalarMappable(cmap="coolwarm", norm=norm)
    sm.set_array([]) # Array to function
    
    # Draw the bar on the plot
    cbar = plt.colorbar(sm, ax=plt.gca())
    cbar.set_label('Ranking', rotation=270, labelpad=15, fontsize=12)

    # Labels/titles
    plt.title('Docking Results (Labeled by Mode)', fontsize=14)
    plt.xlabel('RMSD (Å)', fontsize=12)
    plt.ylabel('Affinity (kcal/mol)', fontsize=12)
    
    plt.tight_layout()
    plt.savefig(plot_file)