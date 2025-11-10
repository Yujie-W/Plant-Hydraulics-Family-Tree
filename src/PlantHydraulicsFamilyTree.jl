module PlantHydraulicsFamilyTree

using CSV
using DataFrames
using Plots
using PyPlot
using Revise


export plot_family_tree


"""

    plot_boxed_text!(ax, x, y, text; fc="white", ljust=48)

Plot a boxed text at position (x, y) on axis `ax`, given
- `ax`: the axis to plot on
- `x`: x coordinate
- `y`: y coordinate
- `text`: the text to plot
- `fc`: face color of the box (default: "white")
- `ljust`: left justification for the box size (default: 48)

"""
function plot_boxed_text!(ax, x, y, text; fc="white", ljust=48)
    box = Dict(:boxstyle => "round,pad=0.5", :fc => fc, :ec => "k", :lw => 1)
    ax.text(x, y, lpad("\n", ljust), ha="center", va="center", fontsize=12, color="k", bbox=box)
    ax.text(x, y, text, ha="center", va="center", fontsize=12)

    return nothing
end;


"""

    get_box_color(role::String)

Get the box color for a given role,
- `Post-doctoral`: "#cab08f"
- `Doctoral`: "#afd4c4"
- `Pre-doctoral`: "#f9e088"
- `Visiting`: "#c9d2d3"
- `Self`: "#ffffff"
- otherwise: "#ff0000" and print a warning message

"""
function get_box_color(role::String)
    if role == "Post-doctoral"
        return "#cab08f"
    elseif role == "Doctoral"
        return "#afd4c4"
    elseif role == "Pre-doctoral"
        return "#f9e088"
    elseif role == "Visiting"
        return "#c9d2d3"
    elseif role == "Self"
        return "#ffffff"
    else
        println("Unknown role: $role")
        return "#ff0000"
    end;
end;


"""

    plot_family_tree(csvfile::String; savepath::Union{String,Nothing}=nothing)

Plot the family tree from a CSV file, given
- `csvfile`: path to the CSV file
- `savepath`: path to save the figure (default: nothing, do not save)

"""
function plot_family_tree(csvfile::String; savepath::Union{String,Nothing}=nothing)
    # read the csv file and determine the figure size
    df = CSV.read(csvfile, DataFrame);
    count_depth_0 = nrow(df[df.Depth .== 0, :]);
    count_depth_2 = nrow(df[df.Depth .== 2, :]);
    max_y_0 = count_depth_0 *  5 + 25;
    min_y_0 = count_depth_0 * -5;
    max_y_2 = count_depth_2 *  5;
    min_y_2 = count_depth_2 * -5;
    max_y = max(max_y_0, max_y_2);
    min_y = min(min_y_0, min_y_2);
    fig_wid = 12;
    fig_hei = (max_y - min_y) / 50 * 12;

    # create the figure and axis
    fig = figure(csvfile, figsize=(fig_wid,fig_hei), dpi=300);
    fig.clear();
    ax = fig.add_axes([0,0,1,1], aspect="equal");
    ax.axis("off");
    ax.set_xlim(-92, 92);
    ax.set_ylim(min_y, max_y+5);

    # plot the node for self
    inode = findfirst(df.Role .== "Self");
    node = df[inode, :];
    plot_boxed_text!(ax, 0, 0, "$(node.Name)\n$(node.Year)");

    # plot the lines from depth 1 to depth 2
    # and then loop through depth 0 and plot the names
    ax.plot([15,25], [0,0], color="k", lw=1);
    ax.plot([25,25], [count_depth_2*-5+5, count_depth_2*5-5], color="k", lw=1);
    inodes2 = findall(df.Depth .== 2);
    for i in eachindex(inodes2)
        node = df[inodes2[i], :];
        ax.plot([25,35], [((count_depth_2-1)/2-i+1)*10, ((count_depth_2-1)/2-i+1)*10], color="k", lw=1);
        plot_boxed_text!(ax, 50, ((count_depth_2-1)/2-i+1)*10, "$(node.Name)", fc=get_box_color(String(node.Role)));
        ax.plot([65,75], [((count_depth_2-1)/2-i+1)*10, ((count_depth_2-1)/2-i+1)*10], color="k", lw=1);
        plot_boxed_text!(ax, 82, ((count_depth_2-1)/2-i+1)*10, "$(node.Year)", ljust=18);
    end;

    # plot the lines from depth 0 to depth 1
    # and then loop through depth 0 and plot the names
    ax.plot([-15,-25], [0,0], color="k", lw=1);
    ax.plot([-25,-25], [count_depth_0*-5+5, count_depth_0*5-5], color="k", lw=1);
    inodes0 = findall(df.Depth .== 0);
    for i in eachindex(inodes0)
        node = df[inodes0[i], :];
        ax.plot([-25,-35], [((count_depth_0-1)/2-i+1)*10, ((count_depth_0-1)/2-i+1)*10], color="k", lw=1);
        plot_boxed_text!(ax, -50, ((count_depth_0-1)/2-i+1)*10, "$(node.Name)", fc=get_box_color(String(node.Role)));
        ax.plot([-65,-75], [((count_depth_0-1)/2-i+1)*10, ((count_depth_0-1)/2-i+1)*10], color="k", lw=1);
        plot_boxed_text!(ax, -82, ((count_depth_0-1)/2-i+1)*10, "$(node.Year)", ljust=18);
    end;

    # plot the legends
    plot_boxed_text!(ax, -75, count_depth_0*5+25, "Post-doctoral", fc=get_box_color("Post-doctoral"), ljust=22);
    plot_boxed_text!(ax, -50, count_depth_0*5+25, "Doctoral", fc=get_box_color("Doctoral"), ljust=22);
    plot_boxed_text!(ax, -75, count_depth_0*5+15, "Pre-doctoral", fc=get_box_color("Pre-doctoral"), ljust=22);
    plot_boxed_text!(ax, -50, count_depth_0*5+15, "Visiting", fc=get_box_color("Visiting"), ljust=22);

    # if the savepath is nothing, do not save the plot
    if isnothing(savepath)
        return fig
    end;

    # if the savepath is given, plot and save the figure
    fig.savefig(savepath, bbox_inches="tight");
    close(fig);

    return nothing
end;


end # module
