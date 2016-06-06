-- Who cares?
--
-- ==
-- compiled input @ small/input-data
-- output @ small/output-data



-- not right now
-- compiled input @ medium/input-data
-- output @ medium/output-data
--



-- Well no
-- compiled input @ large/input-data
-- output @ large/output-data

--default(f32)

type vec3 = (f64, f64, f64)

fun f64 pi() = 3.1415926535897932384626433832795029f64
fun f64 dec2rad(f64 dec) = pi()/180.0f64 * dec
fun f64 rad2dec(f64 rad) = 180.0f64/pi() * rad
fun f64 min_arcmin() = 1.0f64
fun f64 max_arcmin() = 10000.0f64
fun f64 bins_per_dec() = 5.0f64
fun i32 numBins() = 20

fun [f64, num] iota32(i32 num) =
    map(f64, iota(num))

-- Prøv streamRed i stedet
fun *[i64, numBins] sumBins([[i64, numBins], numBinss] bins) =
    map(fn i64 ([i64] binIndex) => reduce(+, 0i64, binIndex), transpose(bins))

fun f64 log10(f64 num) = log64(num) / log64(10.0)

fun *[i64, numBins2] doCompute(
    [vec3, num1] data1,
    [vec3, num2] data2,
    i32 numBins,
    i32 numBins2,
    [f64, numBBins] binb
) =
    let val = map(fn *[i64, numBins2] (f64 xOuter, f64 yOuter, f64 zOuter) =>
            streamMap(fn *[i64, numBins2] (int chunk, [vec3] inner) =>
                    loop (dBins = replicate(numBins2, 0i64)) = for i < chunk do
                        let (xInner, yInner, zInner) = inner[i]
                        let dot = xOuter * xInner + yOuter * yInner + zOuter * zInner
                        loop ((min, max) = (0, numBins)) = while (min+1) < max do
                            let k = (min+max) / 2 in
                            unsafe if dot >= binb[k]
                            then (min, k)
                            else (k, max)
                        in
                        unsafe if dot >= binb[min]
                        then let dBins[min] = dBins[min] + 1i64 in dBins
                        else if dot < binb[max]
                            then let dBins[max+1] = dBins[max+1] + 1i64 in dBins
                            else let dBins[max] = dBins[max] + 1i64 in dBins
                    in dBins
                , data2)
        , data1)
    in
    sumBins(val)

fun *[i64, numBins2] doComputeSelf(
    [vec3, numD] data,
    i32 numBins,
    i32 numBins2,
    [f64, numBBins] binb
) =
-- loop version
    let val = map(fn [i64, numBins2] (vec3 vec, i32 index) =>
                    let (xOuter, yOuter, zOuter) = vec
                    loop (dBins = replicate(numBins2, 0i64)) = for (index+1) <= j < numD do
                        let (xInner, yInner, zInner) = data[j]
                        let dot = xOuter * xInner + yOuter * yInner + zOuter * zInner
                        loop ((min, max) = (0, numBins)) = while (min+1) < max do
                            let k = (min+max) / 2 in
                            unsafe if dot >= binb[k]
                            then (min, k)
                            else (k, max)
                        in
                        unsafe if dot >= binb[min]
                        then let dBins[min] = dBins[min] + 1i64 in dBins
                        else if dot < binb[max]
                            then let dBins[max+1] = dBins[max+1] + 1i64 in dBins
                            else let dBins[max] = dBins[max] + 1i64 in dBins
                    in dBins
                , zip(data, iota(numD)))
    in
    sumBins(val)

fun vec3 fixPoints(f64 ra, f64 dec) =
    let rarad = dec2rad(ra)
    let decrad = dec2rad(dec)
    let cd = cos64(decrad)
    in
    (cos64(rarad)*cd, sin64(rarad)*cd, sin64(decrad))

fun *[i64, 60] main(
    [f64,numD] datapointsx,
    [f64, numD] datapointsy,
    [[f64, numR], numRs] randompointsx,
    [[f64, numR], numRs] randompointsy
) =
    let numBins2 = numBins() + 2
    let binb = map(fn f64 (f64 k) =>
                        cos64((10.0 ** (log10(min_arcmin()) + k*1.0/bins_per_dec())) / 60.0 * dec2rad(1.0)),
                    iota32(numBins() + 1))
    let Datapoints = map(fixPoints, zip(datapointsx, datapointsy))
    let Randompoints = map(fn [vec3, numR] ([f64, numR] x, [f64, numR] y) =>
                            map(fixPoints, zip(x,y)),
                           zip(randompointsx, randompointsy))
    --let (RRs, DRs) = unzip(map(fn (*[i64], *[i64]) ([vec3, numR] random) =>
    --                            (doComputeSelf(random, numBins(), numBins2, binb),
    --                            doCompute(Datapoints, random, numBins(), numBins2, binb)),
    --                           Randompoints))
    let RRs = map(fn *[i64] ([vec3, numR] random) =>
                                doComputeSelf(random, numBins(), numBins2, binb),
                              Randompoints)
    let DRs = map(fn *[i64] ([vec3, numR] random) =>
                                doCompute(Datapoints, random, numBins(), numBins2, binb),
                              Randompoints)
    loop ((res, DD, RR, DR) = (replicate(numBins()*3, 0i64),
                               doComputeSelf(Datapoints, numBins(), numBins2, binb),
                               sumBins(RRs),
                               sumBins(DRs))) = for i < numBins() do
        let res[i*3] = DD[i+1]
        let res[i*3+1] = DR[i+1]
        let res[i*3+2] = RR[i+1]
        in
        (res, DD, RR, DR)
    in
    res
