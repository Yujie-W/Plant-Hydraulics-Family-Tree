# Plant Hydraulics Family Tree

```@example preview
using FileIO
using Images

# Run python to plot the family tree
cp("../../test/test.csv", "test.csv"; force = true);
cmd = `python3 plot-family-tree.py test.csv`;
run(cmd);

# Display the figure
img = load("test-family-tree.png")

```
