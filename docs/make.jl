using Documenter


# define default docs pages
pages = Pair{Any,Any}[
    "Home" => "index.md",
]


# format the docs
mathengine = MathJax(
    Dict(
        :TeX => Dict(
            :equationNumbers => Dict(:autoNumber => "AMS"),
            :Macros => Dict()
        )
    )
);

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    mathengine = mathengine,
    collapselevel = 1,
    assets = ["assets/favicon.ico"]
);


# build the docs
makedocs(
    sitename = "Plant Hydraulics Family Tree",
    checkdocs = :none,
    clean = false,
    format = format,
    pages = pages,
);


# deploy the docs to Github gh-pages
deploydocs(
    repo = "github.com/Yujie-W/Plant-Hydraulics-Family-Tree.git",
    target = "build",
    devbranch = "main",
    push_preview = true,
);
