context("pcrelate tests")
library(SeqVarTools)

test_that("pcrelate2 - variant blocks", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    seqResetFilter(svd, verbose=FALSE)
    iterator <- SeqVarBlockIterator(svd, variantBlock=500, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    expect_equal(myrel, myrel2)
    seqClose(svd)
})

test_that("pcrelate2 - 2 sample blocks", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    resetIterator(iterator, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, sample.block.size=50, verbose=FALSE)
    expect_equal(myrel, myrel2)
    seqClose(svd)
})

test_that("pcrelate2 - >2 sample blocks", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    resetIterator(iterator, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, sample.block.size=20, verbose=FALSE)
    expect_equal(myrel, myrel2)
    seqClose(svd)
})

test_that("pcrelate2 - sample include", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    set.seed(90); samp.incl <- sample(seqGetData(svd, "sample.id"), 50)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, sample.include=samp.incl, verbose=FALSE)
    expect_true(setequal(myrel2$kinSelf$ID, samp.incl))
    seqClose(svd)
})

test_that("pcrelate2 - sample filter", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    seqSetFilter(svd, sample.sel=1:20, verbose=FALSE)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    expect_true(setequal(myrel2$kinSelf$ID, seqGetData(iterator, "sample.id")))
    seqClose(svd)
})

test_that("pcrelate2 - GenotypeData - variant blocks", {
    gd <- .testGenoData()
    mypcs <- .testGenoPCs(gd)
    iterator <- GWASTools::GenotypeBlockIterator(gd)
    myrel <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    iterator <- GWASTools::GenotypeBlockIterator(gd, snpBlock=1000)
    myrel2 <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    expect_equal(myrel, myrel2)
    GWASTools::close(gd)
})

test_that("pcrelate2 - GenotypeData - sample blocks", {
    gd <- .testGenoData()
    mypcs <- .testGenoPCs(gd)
    iterator <- GWASTools::GenotypeBlockIterator(gd)
    myrel <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    iterator <- GWASTools::GenotypeBlockIterator(gd)
    myrel2 <- pcrelate(iterator, pcs = mypcs, sample.block.size=50, verbose=FALSE)
    expect_equal(myrel, myrel2)
    GWASTools::close(gd)
})

test_that("pcrelate2 - GenotypeData - sample include", {
    gd <- .testGenoData()
    mypcs <- .testGenoPCs(gd)
    set.seed(91); samp.incl <- sample(GWASTools::getScanID(gd), 50)
    iterator <- GWASTools::GenotypeBlockIterator(gd)
    myrel2 <- pcrelate(iterator, pcs = mypcs, sample.include=samp.incl, verbose=FALSE)
    expect_true(setequal(myrel2$kinSelf$ID, as.character(samp.incl)))
    GWASTools::close(gd)
})

test_that("pcrelate2 - small sample correction", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    resetIterator(iterator, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, small.samp.correct = TRUE, verbose=FALSE)
    expect_equal(myrel$kinBtwn[,1:2], myrel2$kinBtwn[,1:2])
    seqClose(svd)
})

test_that("pcrelate2 - scale=variant", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    resetIterator(iterator, verbose=FALSE)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, scale="variant", verbose=FALSE)
    expect_equal(myrel$kinBtwn[,1:2], myrel2$kinBtwn[,1:2])
    seqClose(svd)
})

test_that("pcrelate2 - scale=none", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    resetIterator(iterator, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, scale="none", ibd.probs=FALSE, verbose=FALSE)
    expect_equal(myrel$kinBtwn[,1:2], myrel2$kinBtwn[,1:2])
    seqClose(svd)
})

test_that("pcrelate2 - method=truncate", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel.f <- pcrelate(iterator, pcs = mypcs, maf.bound.method="filter", verbose=FALSE)
    myrel.t <- pcrelate(iterator, pcs = mypcs, maf.bound.method="truncate", verbose=FALSE)
    expect_true(all(myrel.t$nsnp > myrel.f$nsnp))
    expect_equal(myrel.t$kin, myrel.f$kin, tolerance=0.01)
    seqClose(svd)
})

test_that("pcrelate2 - make GRM", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    myrel2 <- pcrelate(iterator, pcs = mypcs, verbose=FALSE)
    grm2 <- pcrelateToMatrix(myrel2, scaleKin=1, verbose=FALSE)
    expect_equivalent(myrel2$kinBtwn$kin[1:10], grm2[2:11,1])
    seqClose(svd)
})

test_that("pcrelateSampBlock with 1 sample in block 1", {
    svd <- .testData()
    mypcs <- .testPCs(svd)
    iterator <- SeqVarBlockIterator(svd, verbose=FALSE)
    samp <- seqGetData(svd, "sample.id")
    beta <- calcISAFBeta(iterator, pcs=mypcs, sample.include=samp[1:10], verbose=FALSE)
    resetIterator(iterator, verbose=FALSE)
    myrel <- pcrelateSampBlock(iterator, betaobj=beta, pcs=mypcs,
                               sample.include.block1=samp[1],
                               sample.include.block2=samp[2:10],
                               verbose=FALSE)
    expect_equal(nrow(myrel$kinBtwn), 9)
    seqClose(svd)
})
