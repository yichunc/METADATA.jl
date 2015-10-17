if VERSION < v"0.4-"
    startswith = beginswith
end

const url_reg = r"^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?"
const gh_path_reg_git=r"^/(.*)?/(.*)?.git$"

const releasejuliaver = v"0.4" #Current release version of Julia
const minjuliaver = v"0.3.0" #Oldest Julia version allowed to be registered
const minpkgver = v"0.0.1"   #Oldest package version allowed to be registered

print_list_3582 = false # set this to true to generate the list of grandfathered
                        # packages permitted under Issue #3582
list_3582 = Any[]

#Issue 2064 - check that all listed packages at at least one tagged version
#2064## Uncomment the #2064# code blocks to generate the list of grandfathered
#2064## packages permitted
for pkg in readdir("METADATA")
    startswith(pkg, ".") && continue
    isfile(joinpath("METADATA", pkg)) && continue
    pkg in [
        "AuditoryFilters",
        "CorpusTools",
        "Elemental",
        "ErrorFreeTransforms",
        "Evapotranspiration",
        "GtkSourceWidget",
        "HiRedis",
        "KrylovMethods",
        "KyotoCabinet",
        "LatexPrint",
        "MachO",
        "MathLink",
        "ObjectiveC",
        "OffsetArrays",
        "Processing",
        "RaggedArrays",
        "RationalExtensions",
        "SolveBio",
        "SortPerf",
    ] && continue
    if !("versions" in readdir(joinpath("METADATA", pkg)))
        #2064#println("        \"", pkg, "\","); continue
        error("Package $pkg has no tagged versions")
    end
end

for (pkg, versions) in Pkg.Read.available()
    url = Pkg.Read.url(pkg)
    if length(versions) <= 0
        error("Package $pkg has no tagged versions.")
    end
    maxv = sort(collect(keys(versions)))[end]
    m = match(url_reg, url)
    if m === nothing || length(m.captures) < 5
        error("Invalid url $url for package $pkg. Should satisfy $url_reg")
    end
    host = m.captures[4]
    if host === nothing
        error("Invalid url $url for package $pkg. Cannot extract host")
    end
    path = m.captures[5]
    if path === nothing
        error("Invalid url $url for package $pkg. Cannot extract path")
    end
    scheme = m.captures[2]
    if !(ismatch(r"git", scheme) || ismatch(r"https", scheme))
        error("Invalid url scheme $scheme for package $pkg. Should be 'git' or 'https'")
    end
    if ismatch(r"github\.com", host)
        m2 = match(gh_path_reg_git, path)
        if m2 == nothing
            error("Invalid GitHub url pattern $url for package $pkg. Should satisfy $gh_path_reg_git")
        end
        user = m2.captures[1]
        repo = m2.captures[2]

        for (ver, avail) in versions
            # Check that all sha1 files have the correct version hashes
            sha1_file = joinpath("METADATA", pkg, "versions", string(ver), "sha1")
            if !isfile(sha1_file)
                error("Not a file: $sha1_file")
            end
            sha1fromfile = open(readchomp, sha1_file)
            @assert sha1fromfile == avail.sha1
        end

        #Issue #2057 - naming convention check
        if endswith(pkg, ".jl")
            error("Package name $pkg should not end in .jl")
        end
        if !endswith(repo, ".jl")
            error("Repository name $repo does not end in .jl")
        end

        sha1_file = joinpath("METADATA", pkg, "versions", string(maxv), "sha1")
        if !isfile(sha1_file)
            error("File not found: $sha1_file")
        end

        #Issue #3582 - check that newest version of a package is at least minpkgver
        #and furthermore has a requires file listing a minimum Julia version
        #that is at least minjuliaver
        if print_list_3582 || !((pkg, maxv) in ( #List of grandfathered packages
            ("ASCIIPlots", v"0.0.3"), #1
            ("AWS", v"0.1.13"), #2
            ("ActiveAppearanceModels", v"0.1.2"), #3
            ("AffineTransforms", v"0.1.1"), #4
            ("AnsiColor", v"0.0.2"), #5
            ("AppleAccelerate", v"0.1.0"), #6
            ("Arbiter", v"0.0.2"), #7
            ("Arduino", v"0.1.2"), #8
            ("Arrowhead", v"0.0.1"), #9
            ("Atom", v"0.1.1"), #10
            ("AudioIO", v"0.1.1"), #11
            ("Autoreload", v"0.2.0"), #12
            ("AxisAlgorithms", v"0.1.3"), #13
            ("BDF", v"0.1.2"), #14
            ("BEncode", v"0.1.1"), #15
            ("BSplines", v"0.0.3"), #16
            ("BackpropNeuralNet", v"0.0.3"), #17
            ("BaseTestDeprecated", v"0.1.0"), #18
            ("Bebop", v"0.0.1"), #19
            ("Benchmark", v"0.1.0"), #20
            ("BenchmarkLite", v"0.1.2"), #21
            ("Bio", v"0.1.0"), #22
            ("BioSeq", v"0.4.0"), #23
            ("BiomolecularStructures", v"0.0.1"), #24
            ("Biryani", v"0.2.0"), #25
            ("BlackBoxOptim", v"0.0.1"), #26
            ("Blocks", v"0.1.0"), #27
            ("BlossomV", v"0.0.1"), #28
            ("BoundingBoxes", v"0.1.0"), #29
            ("Brownian", v"0.0.1"), #30
            ("BufferedStreams", v"0.0.1"), #31
            ("BusinessDays", v"0.0.5"), #32
            ("CLBLAS", v"0.1.0"), #33
            ("CLFFT", v"0.1.0"), #34
            ("CPUTime", v"0.0.4"), #35
            ("CRC32", v"0.0.2"), #36
            ("CRF", v"0.1.1"), #37
            ("CUBLAS", v"0.0.2"), #38
            ("CUDA", v"0.1.0"), #39
            ("CUDArt", v"0.2.2"), #40
            ("CUDNN", v"0.2.0"), #41
            ("CUFFT", v"0.0.3"), #42
            ("CURAND", v"0.0.4"), #43
            ("CUSOLVER", v"0.0.1"), #44
            ("CUSPARSE", v"0.3.0"), #45
            ("Calendar", v"0.4.3"), #46
            ("CasaCore", v"0.0.3"), #47
            ("Catalan", v"0.0.3"), #48
            ("CauseMap", v"0.0.3"), #49
            ("CellularAutomata", v"0.1.2"), #50
            ("ChainedVectors", v"0.0.0"), #51
            ("ChaosCommunications", v"0.0.1"), #52
            ("ChemicalKinetics", v"0.1.0"), #53
            ("Chipmunk", v"0.0.5"), #54
            ("Church", v"0.0.1"), #55
            ("CirruParser", v"0.0.2"), #56
            ("Clang", v"0.0.5"), #57
            ("Cliffords", v"0.2.3"), #58
            ("ClusterManagers", v"0.0.5"), #59
            ("Clustering", v"0.4.0"), #60
            ("CodeTools", v"0.1.0"), #61
            ("CommonCrawl", v"0.0.1"), #62
            ("CompilerOptions", v"0.1.0"), #63
            ("CompressedSensing", v"0.0.2"), #64
            ("ConfParser", v"0.0.6"), #65
            ("ConfidenceWeighted", v"0.0.2"), #66
            ("ContinuedFractions", v"0.0.0"), #67
            ("Contour", v"0.0.8"), #68
            ("CoreNLP", v"0.1.0"), #69
            ("Cosmology", v"0.1.3"), #70
            ("Coverage", v"0.2.3"), #71
            ("CoverageBase", v"0.0.3"), #72
            ("Cpp", v"0.1.0"), #73
            ("CrossDecomposition", v"0.0.1"), #74
            ("Curl", v"0.0.3"), #75
            ("DASSL", v"0.0.4"), #76
            ("DCEMRI", v"0.1.1"), #77
            ("DICOM", v"0.0.1"), #78
            ("DReal", v"0.0.2"), #79
            ("DWARF", v"0.0.0"), #80
            ("DataFramesMeta", v"0.0.1"), #81
            ("Dates", v"0.4.4"), #82
            ("Datetime", v"0.1.7"), #83
            ("DecFP", v"0.1.1"), #84
            ("DeclarativePackages", v"0.1.2"), #85
            ("DevIL", v"0.2.2"), #86
            ("DictFiles", v"0.1.0"), #87
            ("DictUtils", v"0.0.2"), #88
            ("DimensionalityReduction", v"0.1.2"), #89
            ("DirichletProcessMixtures", v"0.0.1"), #90
            ("DiscreteFactor", v"0.0.0"), #91
            ("Distance", v"0.5.1"), #92
            ("Docker", v"0.0.0"), #93
            ("DoubleDouble", v"0.1.0"), #94
            ("Drawing", v"0.1.3"), #95
            ("Dynare", v"0.0.1"), #96
            ("ELF", v"0.0.0"), #97
            ("ERFA", v"0.1.0"), #98
            ("Elliptic", v"0.2.0"), #99
            ("Elly", v"0.0.4"), #100
            ("Equations", v"0.1.1"), #101
            ("Etcd", v"0.0.1"), #102
            ("ExpressionUtils", v"0.0.0"), #103
            ("ExtremelyRandomizedTrees", v"0.1.0"), #104
            ("FLANN", v"0.0.2"), #105
            ("FMIndexes", v"0.0.1"), #106
            ("FTPClient", v"0.1.1"), #107
            ("FaceDatasets", v"0.1.4"), #108
            ("Faker", v"0.0.1"), #109
            ("FastAnonymous", v"0.3.2"), #110
            ("FastArrayOps", v"0.1.0"), #111
            ("FileFind", v"0.0.0"), #112
            ("FinancialMarkets", v"0.1.1"), #113
            ("FiniteStateMachine", v"0.0.2"), #114
            ("FixedEffectModels", v"0.2.2"), #115
            ("FixedPoint", v"0.0.1"), #116
            ("FixedSizeArrays", v"0.0.6"), #117
            ("Fixtures", v"0.0.2"), #118
            ("ForwardDiff", v"0.1.1"), #119
            ("FreeType", v"1.0.1"), #120
            ("FunctionalCollections", v"0.1.2"), #121
            ("FunctionalData", v"0.1.0"), #122
            ("FunctionalDataUtils", v"0.1.0"), #123
            ("FunctionalUtils", v"0.0.0"), #124
            ("GARCH", v"0.1.2"), #125
            ("GLAbstraction", v"0.0.6"), #126
            ("GLPlot", v"0.0.5"), #127
            ("GLText", v"0.0.4"), #128
            ("GLUT", v"0.4.0"), #129
            ("GLVisualize", v"0.0.2"), #130
            ("GLWindow", v"0.0.6"), #131
            ("GSL", v"0.2.0"), #132
            ("Gaston", v"0.0.0"), #133
            ("GaussianProcesses", v"0.1.2"), #134
            ("GeneticAlgorithms", v"0.0.3"), #135
            ("GeoStats", v"0.0.2"), #136
            ("GeoStatsImages", v"0.0.1"), #137
            ("GeometricalPredicates", v"0.0.4"), #138
            ("GeometryTypes", v"0.0.3"), #139
            ("GetC", v"1.1.1"), #140
            ("Gettext", v"0.1.0"), #141
            ("GibbsSeaWater", v"0.0.4"), #142
            ("Glob", v"1.0.1"), #143
            ("GradientBoost", v"0.0.1"), #144
            ("GraphLayout", v"0.2.0"), #145
            ("Graphics", v"0.1.3"), #146
            ("GreatCircle", v"0.0.1"), #147
            ("Grid", v"0.4.0"), #148
            ("Gtk", v"0.9.2"), #149
            ("GtkUtilities", v"0.0.6"), #150
            ("HTTP", v"0.0.2"), #151
            ("HTTPClient", v"0.1.6"), #152
            ("Hadamard", v"0.1.2"), #153
            ("Helpme", v"0.0.13"), #154
            ("HexEdit", v"0.0.4"), #155
            ("Hexagons", v"0.0.4"), #156
            ("Hiccup", v"0.0.1"), #157
            ("HopfieldNets", v"0.0.0"), #158
            ("HttpCommon", v"0.2.4"), #159
            ("HttpParser", v"0.1.1"), #160
            ("HttpServer", v"0.1.4"), #161
            ("Humanize", v"0.4.0"), #162
            ("Hwloc", v"0.2.0"), #163
            ("HyperDualNumbers", v"0.1.7"), #164
            ("HyperLogLog", v"0.0.0"), #165
            ("ICU", v"0.4.4"), #166
            ("IDRsSolver", v"0.1.3"), #167
            ("IDXParser", v"0.1.0"), #168
            ("IPPCore", v"0.2.1"), #169
            ("IPPDSP", v"0.0.1"), #170
            ("IProfile", v"0.3.1"), #171
            ("ImageQuilting", v"0.2.2"), #172
            ("Immerse", v"0.0.8"), #173
            ("IndexableBitVectors", v"0.1.0"), #174
            ("IndexedArrays", v"0.1.0"), #175
            ("InformedDifferentialEvolution", v"0.1.0"), #176
            ("IniFile", v"0.2.4"), #177
            ("InplaceOps", v"0.0.4"), #178
            ("Instruments", v"0.0.1"), #179
            ("IntArrays", v"0.0.1"), #180
            ("InterestRates", v"0.0.2"), #181
            ("Interfaces", v"0.0.4"), #182
            ("Interpolations", v"0.3.2"), #183
            ("IntervalTrees", v"0.0.4"), #184
            ("Isotonic", v"0.0.1"), #185
            ("IterationManagers", v"0.0.1"), #186
            ("IterativeSolvers", v"0.2.1"), #187
            ("Ito", v"0.0.2"), #188
            ("JFVM", v"0.0.1"), #189
            ("JLDArchives", v"0.0.6"), #190
            ("JPLEphemeris", v"0.2.1"), #191
            ("JellyFish", v"0.0.1"), #192
            ("JointMoments", v"0.2.5"), #193
            ("JudyDicts", v"0.0.0"), #194
            ("JuliaFEM", v"0.0.1"), #195
            ("JuliaParser", v"0.6.3"), #196
            ("JuliaWebRepl", v"0.0.0"), #197
            ("JulieTest", v"0.0.2"), #198
            ("Jumos", v"0.2.1"), #199
            ("KLDivergence", v"0.0.0"), #200
            ("KShiftsClustering", v"0.1.0"), #201
            ("KernSmooth", v"0.0.3"), #202
            ("LARS", v"0.0.3"), #203
            ("LIBSVM", v"0.0.1"), #204
            ("LMDB", v"0.0.4"), #205
            ("LNR", v"0.0.1"), #206
            ("LRUCache", v"0.0.1"), #207
            ("LaTeX", v"0.1.0"), #208
            ("LambertW", v"0.0.4"), #209
            ("LazySequences", v"0.1.0"), #210
            ("LibCURL", v"0.1.6"), #211
            ("LibGit2", v"0.3.8"), #212
            ("LibHealpix", v"0.0.1"), #213
            ("LibTrading", v"0.0.1"), #214
            ("Libz", v"0.0.1"), #215
            ("LineEdit", v"0.0.1"), #216
            ("LinearMaps", v"0.1.1"), #217
            ("LinguisticData", v"0.0.2"), #218
            ("Lint", v"0.1.68"), #219
            ("LogParser", v"0.2.0"), #220
            ("Lora", v"0.4.4"), #221
            ("Loss", v"0.0.1"), #222
            ("LowDimNearestNeighbors", v"0.0.1"), #223
            ("Lumira", v"0.0.2"), #224
            ("MATLABCluster", v"0.0.1"), #225
            ("MCMC", v"0.3.0"), #226
            ("MDCT", v"0.0.2"), #227
            ("MDPs", v"0.1.1"), #228
            ("MIToS", v"0.1.0"), #229
            ("MPFI", v"0.0.1"), #230
            ("MPI", v"0.3.2"), #231
            ("MUMPS", v"0.0.1"), #232
            ("MachineLearning", v"0.0.3"), #233
            ("ManifoldLearning", v"0.1.0"), #234
            ("MapLight", v"0.0.2"), #235
            ("Markdown", v"0.3.0"), #236
            ("MarketData", v"0.3.2"), #237
            ("MarketTechnicals", v"0.4.1"), #238
            ("Mathematica", v"0.2.0"), #239
            ("MbedTLS", v"0.1.4"), #240
            ("Media", v"0.1.1"), #241
            ("MelGeneralizedCepstrums", v"0.0.1"), #242
            ("Memoize", v"0.0.0"), #243
            ("MeshIO", v"0.0.2"), #244
            ("Meshing", v"0.0.0"), #245
            ("MessageUtils", v"0.0.2"), #246
            ("MetaTools", v"0.0.1"), #247
            ("Millboard", v"0.0.6"), #248
            ("MinimalPerfectHashes", v"0.1.2"), #249
            ("MixedModels", v"0.4.0"), #250
            ("MixtureModels", v"0.2.0"), #251
            ("MolecularDynamics", v"0.1.3"), #252
            ("Monads", v"0.0.0"), #253
            ("Mongrel2", v"0.0.0"), #254
            ("MsgPackRpcClient", v"0.0.0"), #255
            ("MultiNest", v"0.2.0"), #256
            ("MultiPoly", v"0.0.1"), #257
            ("Multirate", v"0.0.2"), #258
            ("Murmur3", v"0.1.0"), #259
            ("MutableStrings", v"0.0.0"), #260
            ("NFFT", v"0.0.2"), #261
            ("NHST", v"0.0.2"), #262
            ("NIDAQ", v"0.0.2"), #263
            ("NLreg", v"0.1.1"), #264
            ("NMEA", v"0.0.4"), #265
            ("NMF", v"0.2.4"), #266
            ("NPZ", v"0.0.1"), #267
            ("NURBS", v"0.0.1"), #268
            ("NaiveBayes", v"0.1.0"), #269
            ("Named", v"0.0.0"), #270
            ("NamedDimensions", v"0.0.3"), #271
            ("NamedTuples", v"0.0.2"), #272
            ("Neovim", v"0.0.2"), #273
            ("NetCDF", v"0.2.1"), #274
            ("NeuralynxNCS", v"0.0.1"), #275
            ("NullableArrays", v"0.0.1"), #276
            ("NumericExtensions", v"0.6.2"), #277
            ("OAuth", v"0.3.0"), #278
            ("OCCA", v"0.0.1"), #279
            ("ODBC", v"0.3.10"), #280
            ("OSC", v"0.0.1"), #281
            ("OSXNotifier", v"0.0.1"), #282
            ("OnlineStats", v"0.3.0"), #283
            ("OpenGL", v"2.0.3"), #284
            ("OpenSSL", v"0.0.0"), #285
            ("OpenSecrets", v"0.0.1"), #286
            ("OpenSlide", v"0.0.1"), #287
            ("OptimPack", v"0.1.2"), #288
            ("Orchestra", v"0.0.5"), #289
            ("PAINTER", v"0.1.2"), #290
            ("PEGParser", v"0.1.2"), #291
            ("PGFPlots", v"1.2.2"), #292
            ("PGM", v"0.0.1"), #293
            ("PLX", v"0.0.5"), #294
            ("PTools", v"0.0.0"), #295
            ("PValueAdjust", v"2.0.0"), #296
            ("Packing", v"0.0.2"), #297
            ("PairwiseListMatrices", v"0.1.1"), #298
            ("Pandas", v"0.2.0"), #299
            ("Pardiso", v"0.0.2"), #300
            ("PatternDispatch", v"0.0.2"), #301
            ("Pcap", v"0.0.1"), #302
            ("Pedigrees", v"0.0.1"), #303
            ("Permutations", v"0.0.1"), #304
            ("Phylogenetics", v"0.0.2"), #305
            ("PicoSAT", v"0.1.0"), #306
            ("Playground", v"0.0.3"), #307
            ("Plotly", v"0.0.3"), #308
            ("PolarFact", v"0.0.5"), #309
            ("Polynomial", v"0.1.1"), #310
            ("ProfileView", v"0.1.1"), #311
            ("ProgressMeter", v"0.2.1"), #312
            ("ProjectTemplate", v"0.0.1"), #313
            ("PropertyGraph", v"0.1.0"), #314
            ("Push", v"0.0.1"), #315
            ("PyLexYacc", v"0.0.2"), #316
            ("PySide", v"0.0.2"), #317
            ("Quandl", v"0.5.0"), #318
            ("Quaternions", v"0.0.4"), #319
            ("QuickCheck", v"0.0.0"), #320
            ("QuickShiftClustering", v"0.1.0"), #321
            ("RDF", v"0.0.1"), #322
            ("RDatasets", v"0.1.2"), #323
            ("REPL", v"0.0.2"), #324
            ("REPLCompletions", v"0.0.3"), #325
            ("RLEVectors", v"0.0.1"), #326
            ("RandomFerns", v"0.1.0"), #327
            ("RdRand", v"0.0.0"), #328
            ("React", v"0.1.6"), #329
            ("Redis", v"0.0.1"), #330
            ("Reel", v"0.1.0"), #331
            ("Reexport", v"0.0.3"), #332
            ("Requests", v"0.3.2"), #333
            ("Resampling", v"0.0.0"), #334
            ("ReverseDiffOverload", v"0.0.1"), #335
            ("Rif", v"0.0.12"), #336
            ("Rmath", v"0.0.0"), #337
            ("RobustShortestPath", v"0.2.1"), #338
            ("RobustStats", v"0.0.1"), #339
            ("RomanNumerals", v"0.1.0"), #340
            ("RudeOil", v"0.1.0"), #341
            ("RunTests", v"0.0.3"), #342
            ("SCS", v"0.1.1"), #343
            ("SDE", v"0.3.1"), #344
            ("SDL", v"0.1.5"), #345
            ("SFML", v"0.1.0"), #346
            ("SMTPClient", v"0.0.0"), #347
            ("SVM", v"0.0.1"), #348
            ("Sampling", v"0.0.8"), #349
            ("SaveREPL", v"0.0.1"), #350
            ("SemidefiniteProgramming", v"0.1.0"), #351
            ("SerialPorts", v"0.0.5"), #352
            ("ShapeModels", v"0.0.3"), #353
            ("ShowSet", v"0.0.1"), #354
            ("SigmoidalProgramming", v"0.0.1"), #355
            ("Silo", v"0.1.0"), #356
            ("Sims", v"0.1.0"), #357
            ("SkyCoords", v"0.1.0"), #358
            ("SliceSampler", v"0.0.0"), #359
            ("Slugify", v"0.1.1"), #360
            ("Smile", v"0.1.3"), #361
            ("SmoothingKernels", v"0.0.0"), #362
            ("Snappy", v"0.0.1"), #363
            ("Sodium", v"0.0.0"), #364
            ("SoftConfidenceWeighted", v"0.1.2"), #365
            ("Soundex", v"0.0.0"), #366
            ("Sparklines", v"0.1.0"), #367
            ("SpecialMatrices", v"0.1.3"), #368
            ("StackedNets", v"0.0.1"), #369
            ("Stan", v"0.3.1"), #370
            ("Stats", v"0.1.0"), #371
            ("StochasticSearch", v"0.2.0"), #372
            ("StrPack", v"0.0.1"), #373
            ("StreamStats", v"0.0.2"), #374
            ("StructsOfArrays", v"0.0.3"), #375
            ("SuffixArrays", v"0.0.1"), #376
            ("Sundials", v"0.1.3"), #377
            ("SunlightAPIs", v"0.0.3"), #378
            ("Switch", v"0.0.1"), #379
            ("Synchrony", v"0.0.1"), #380
            ("SynthesisFilters", v"0.0.1"), #381
            ("Taro", v"0.2.0"), #382
            ("Tau", v"0.0.3"), #383
            ("TensorOperations", v"0.3.1"), #384
            ("TermWin", v"0.0.31"), #385
            ("TerminalExtensions", v"0.0.2"), #386
            ("Terminals", v"0.0.1"), #387
            ("TestImages", v"0.0.8"), #388
            ("TexExtensions", v"0.0.2"), #389
            ("TextPlots", v"0.3.0"), #390
            ("ThermodynamicsTable", v"0.0.3"), #391
            ("ThingSpeak", v"0.0.2"), #392
            ("TimeSeries", v"0.6.4"), #393
            ("TimeZones", v"0.1.0"), #394
            ("TopicModels", v"0.0.1"), #395
            ("TrafficAssignment", v"0.2.0"), #396
            ("Trie", v"0.0.0"), #397
            ("Twitter", v"0.2.2"), #398
            ("TypeCheck", v"0.0.3"), #399
            ("Typeclass", v"0.0.1"), #400
            ("UAParser", v"0.3.0"), #401
            ("URIParser", v"0.1.1"), #402
            ("URITemplate", v"0.0.1"), #403
            ("URLParse", v"0.0.0"), #404
            ("UTF16", v"0.3.0"), #405
            ("Units", v"0.2.6"), #406
            ("VML", v"0.0.1"), #407
            ("VStatistic", v"1.0.0"), #408
            ("ValueDispatch", v"0.0.0"), #409
            ("VennEuler", v"0.0.1"), #410
            ("VoronoiDelaunay", v"0.0.1"), #411
            ("Voting", v"0.0.1"), #412
            ("Wallace", v"0.0.1"), #413
            ("Watcher", v"0.1.0"), #414
            ("WaveletMatrices", v"0.1.0"), #415
            ("Winston", v"0.11.13"), #416
            ("WorldBankData", v"0.0.4"), #417
            ("XClipboard", v"0.0.3"), #418
            ("XGBoost", v"0.1.0"), #419
            ("XSV", v"0.0.2"), #420
            ("YT", v"0.2.0"), #421
            ("Yelp", v"0.3.0"), #422
            ("ZChop", v"0.0.2"), #423
            ("ZVSimulator", v"0.0.0"), #424
            ("kNN", v"0.0.0"), #425
            ))
            try
                if maxv < minpkgver
                    error("$pkg: version $maxv no longer allowed (>= $minpkgver needed)")
                end
                requires_file = joinpath("METADATA", pkg, "versions", string(maxv), "requires")
                if !isfile(requires_file)
                    error("File not found: $requires_file")
                end
                open(requires_file) do f
                    hasjuliaver = false
                    for line in eachline(f)
                        if startswith(line, "julia")
                            tokens = split(line)
                            if length(tokens) <= 1
                                error("$requires_file: oldest allowed julia version not specified (>= $minjuliaver needed)")
                            end
                            juliaver = convert(VersionNumber, tokens[2])
                            if juliaver < minjuliaver
                                error("$requires_file: oldest allowed julia version $juliaver too old (>= $minjuliaver needed)")
                            end
                            if (juliaver < releasejuliaver && juliaver.patch==0 &&
                                (juliaver.prerelease != () || juliaver.build != ()))
                                #No prereleases older than current release allowed
                                error("$requires_file: prerelease $juliaver not allowed (>= $releasejuliaver needed)")
                            end
                            hasjuliaver = true
                        end
                    end
                    if !hasjuliaver
                        error("$requires_file: no julia entry (>= $minjuliaver needed)")
                    end
                end
            catch err
                if print_list_3582
                    push!(list_3582, (pkg, maxv))
                else
                    rethrow(err)
                end
            end
        end
    end
end
if print_list_3582
    sort!(list_3582, by=first)
    for npkg in 1:length(list_3582)
        pkg, maxv = list_3582[npkg]
        println("""            ("$pkg", v"$maxv"), #$npkg""")
    end
end

info("Checking that all entries in METADATA are recognized packages...")

#Scan all entries in METADATA for possibly unrecognized packages
const pkgs = [pkg for (pkg, versions) in Pkg.Read.available()]

for pkg in readdir("METADATA")
    #Traverse the 'versions' directory and make sure that we understand its contents
    #The only allowed subdirectories must be semvers and the only allowed
    #files within are 'sha1' and 'requires'
    #
    #Ref: #2040
    verinfodir = joinpath("METADATA", pkg, "versions")
    isdir(verinfodir) || continue #Some packages are registered but have no tagged versions. See #2064

    for verdir in readdir(verinfodir)
        version = try
            convert(VersionNumber, verdir)
        catch ArgumentError
            error("Invalid version number $verdir found in $verinfodir")
        end

        versions = Pkg.Read.available(pkg)
        if version in keys(versions)
           for filename in readdir(joinpath(verinfodir, verdir))
               if !(filename=="sha1" || filename=="requires")
                   relpath = joinpath(verinfodir, verdir, filename)
                   error("Unknown file $relpath encountered. Valid filenames are 'sha1' and 'requires'.")
               end
           end
        else
            relpath = joinpath("METADATA", pkg, "versions", verdir, "sha1")
            error("Version v$verdir of $pkg is not configured correctly. Check that $relpath exists.")
        end
    end
end

info("Verifying METADATA...")
Pkg.Entry.check_metadata()
