#-------------------------------------------------------------------------------------
# pbmc data from csv 
#-------------------------------------------------------------------------------------
"""
    load_pbmc(path::String = joinpath(@__DIR__, "../data/"))

Loads build-in `pbmc` dataset from [Zheng et al. 2017](https://www.nature.com/articles/ncomms14049). 
Specifically, the PBMC8k version is used and has been preprocessed according to the [Bioconductor workflow](https://bioconductor.org/books/3.15/OSCA.workflows/unfiltered-human-pbmcs-10x-genomics.html).

The function loads the following files from the folder passed as `path` (default: `data` subfolder of scVI repo.)
 - `PBMC_counts.csv`: countmatrix  
 - `PBMC_annotation.csv`: cell type annotation

This file can be downloaded by cloning the package Github repository and subsequently using [Git LFS](https://git-lfs.github.com) 
to run `git-lfs checkout` inside the cloned package repo.

From these input files, a Julia `AnnData` object is created. The countmatrix contains information on 
cell barcodes and gene names. The gene name and celltype information is stored in the `vars` and `obs` 
dictionaries of the `AnnData` object, respectively. 

Returns the Julia `AnnData` object.

**Example** 
---------------------------
    julia> load_pbmc()
        AnnData object with a countmatrix with 7480 cells and 200 genes
        unique celltypes: ["B-cells", "CD4+ T-cells", "Monocytes", "CD8+ T-cells", "NK cells", "NA", "HSC", "Erythrocytes"]
        training status: not trained
#
"""
function load_pbmc(path::String = joinpath(@__DIR__, "../data/"))
    filename_counts = joinpath(path, "PBMC_counts.csv")
    filename_annotation = joinpath(path, "PBMC_annotation.csv")
    if isfile(filename_counts) && isfile(filename_annotation)
        counts = CSV.read(filename_counts, DataFrame)
        celltypes = vec(string.(CSV.read(filename_annotation, DataFrame)[:,2]))
        genenames = string.(counts[:,1])
        barcodes = names(counts)[2:end]
        counts = Matrix(counts[:,2:end])
        @assert length(celltypes) == length(barcodes) == size(counts,2)
        counts = Float32.(counts')

        adata = AnnData(countmatrix=counts, 
                    ncells=size(counts,1), 
                    ngenes=size(counts,2), 
                    celltypes = celltypes,
                    obs=Dict("cell_type" => celltypes),
                    vars = Dict("gene_names" => genenames)
        )
    else 
        filename_jld2 = joinpath(path, "pbmc.jld2")
        adata = jldopen(filename_jld2)["adata_pbmc"]
    end
    return adata
end