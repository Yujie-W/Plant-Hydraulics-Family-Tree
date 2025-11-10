# This is an script to read from a CSV about the family tree and then plotted it
# The format of the CSV is (dataframe format)
#     Name                   Depth    Role       Year
#     John S Sperry          1        Self       1959-
#     Martin H Zimmermann    0        Student    1980-1984
#     Melvin T Tyree         0        Postdoc    1984-1989
#     Yujie Wang             2        Student    2015-2019
#     David M Love           2        Student    2013-2018
#     Martin D Venturas      2        Postdoc    2017-2019
#     ...
# This would given a tree like this:
#
#  1980-1984 - Martin H Zimmermann |                      | Martin D Venturas - 2017-2019
#                                  |--> John S Sperry --> |    David M Love   - 2013-2018
#  1984-1989 -    Melvin T Tyree   |                      |     Yujie Wang    - 2015-2019


import matplotlib.pyplot as PLT
import pandas as PD
import os
import sys


# read in the input from shell argument
if len(sys.argv) <= 1:
    print("Please provide the CSV file name!")
    sys.exit(1)
else:
    csv_file = sys.argv[1]
    print(f"Your input CSV file is: {csv_file}")
    if not os.path.exists(csv_file):
        print(f"File {csv_file} does not exist!")
        sys.exit(1)
    else:
        png_file = f"{csv_file.split('.')[0]}-family-tree.png"
        print(f"Family tree will be plotted as {png_file}")


# 0. function to plot text and box
def plot_boxed_text(ax, x, y, text, fc="white", ljust=35):
    box = dict(boxstyle="round,pad=0.5", fc=fc, ec="k", lw=1)
    ax.text(x, y, "\n".ljust(ljust), ha="center", va="center", fontsize=12, color="k", bbox=box)
    ax.text(x, y, text, ha="center", va="center", fontsize=12)

def get_box_color(role):
    if role == "Post-doctoral":
        return "#cab08f"
    elif role == "Doctoral":
        return "#afd4c4"
    elif role == "Pre-doctoral":
        return "#f9e088"
    elif role == "Visiting":
        return "#c9d2d3"
    elif role == "Self":
        return "#ffffff"
    else:
        print(f"Unknown role: {role}")
        return "#ff0000"


# 1. read the CSV file
#    count the number of people at depth 0 and 2
csv_df = PD.read_csv(csv_file)
count_depth_0 = len(csv_df[csv_df["Depth"]==0])
count_depth_2 = len(csv_df[csv_df["Depth"]==2])
max_y_0 = count_depth_0*5+25
min_y_0 = count_depth_0*-5
max_y_2 = count_depth_2*5
min_y_2 = count_depth_2*-5
max_y = max(max_y_0, max_y_2)
min_y = min(min_y_0, min_y_2)

fig_wid = 12
fig_hei = (max_y - min_y)/50*12


# 2. create the canvas
ftree = PLT.figure(figsize=(fig_wid,fig_hei), dpi=300)
ax = ftree.add_axes([0,0,1,1], aspect="equal")
ax.axis("off")
ax.set_xlim(-92,92)
ax.set_ylim(min_y, max_y+5)


# plot the nodes (self at 0,0)
node = csv_df[csv_df["Role"]=="Self"].iloc[0]
plot_boxed_text(ax, 0, 0, f"{node['Name']}\n{node['Year']}")


# plot the lines from depth 1 to depth 2
# and then loop through depth 2 and plot the names
ax.plot([15,25], [0,0], color="k", lw=1)
ax.plot([25,25], [count_depth_2*-5+5, count_depth_2*5-5], color="k", lw=1)
for i in range(count_depth_2):
    node = csv_df[(csv_df["Depth"]==2)].iloc[i]
    ax.plot([25,35], [((count_depth_2-1)/2-i)*10, ((count_depth_2-1)/2-i)*10], color="k", lw=1)
    plot_boxed_text(ax, 50, ((count_depth_2-1)/2-i)*10, f"{node['Name']}", fc=get_box_color(node["Role"]))
    ax.plot([65,75], [((count_depth_2-1)/2-i)*10, ((count_depth_2-1)/2-i)*10], color="k", lw=1)
    plot_boxed_text(ax, 82, ((count_depth_2-1)/2-i)*10, f"{node['Year']}", ljust=18)


# plot the lines from depth 0 to depth 1
# and then loop through depth 0 and plot the names
ax.plot([-15,-25], [0,0], color="k", lw=1)
ax.plot([-25,-25], [count_depth_0*-5+5, count_depth_0*5-5], color="k", lw=1)
for i in range(count_depth_0):
    node = csv_df[(csv_df["Depth"]==0)].iloc[i]
    ax.plot([-25,-35], [((count_depth_0-1)/2-i)*10, ((count_depth_0-1)/2-i)*10], color="k", lw=1)
    plot_boxed_text(ax, -50, ((count_depth_0-1)/2-i)*10, f"{node['Name']}", fc=get_box_color(node["Role"]))
    ax.plot([-65,-75], [((count_depth_0-1)/2-i)*10, ((count_depth_0-1)/2-i)*10], color="k", lw=1)
    plot_boxed_text(ax, -82, ((count_depth_0-1)/2-i)*10, f"{node['Year']}", ljust=18)


# plot the legends
plot_boxed_text(ax, -75, count_depth_0*5+25, "Post-doctoral", fc=get_box_color("Post-doctoral"), ljust=22)
plot_boxed_text(ax, -50, count_depth_0*5+25, "Doctoral", fc=get_box_color("Doctoral"), ljust=22)
plot_boxed_text(ax, -75, count_depth_0*5+15, "Pre-doctoral", fc=get_box_color("Pre-doctoral"), ljust=22)
plot_boxed_text(ax, -50, count_depth_0*5+15, "Visiting", fc=get_box_color("Visiting"), ljust=22)


# save the figure
ftree.savefig(png_file, bbox_inches="tight")
print(f"Family tree saved as {png_file}")
