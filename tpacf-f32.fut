-- An implementation of the tpacf benchmark from the parboil benchmark suite
--
-- ==
-- compiled input @ small/input-data
-- output @ small/output-data
-- compiled input @ medium/input-data
-- output @ medium/output-data
-- compiled input @ large/input-data
-- output @ large/output-data

default(f32)

type vec3 = (f32, f32, f32)

fun f32 pi() = 3.1415926535897932384626433832795029f32
fun f32 dec2rad(f32 dec) = pi()/180.0f32 * dec
fun f32 rad2dec(f32 rad) = 180.0f32/pi() * rad
fun f32 min_arcmin() = 1.0f32
fun f32 max_arcmin() = 10000.0f32
fun f32 bins_per_dec() = 5.0f32
fun i32 numBins() = 20

fun [f32, num] iota32(i32 num) =
    map(f32, iota(num))

-- Prøv streamRed i stedet
fun *[i64, numBins] sumBins([[i64, numBins], numBinss] bins) =
    map(fn i64 ([i64] binIndex) => reduce(+, 0i64, binIndex), transpose(bins))

fun f32 log10(f32 num) = log32(num) / log32(10.0)

fun *[i64, numBins2] doCompute(
    [vec3, num1] data1,
    [vec3, num2] data2,
    i32 numBins,
    i32 numBins2,
    [f32, numBBins] binb
) =
    let value = map(fn *[i64, numBins2] (f32 xOuter, f32 yOuter, f32 zOuter) =>
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
                        let index = unsafe if dot >= binb[min]
                                    then min
                                    else if dot < binb[max]
                                        then max+1
                                        else max
                        in
                        unsafe let dBins[index] = dBins[index] + 1i64 in dBins
                    in dBins
                , data2)
        , data1)
    in
    sumBins(value)

fun *[i64, numBins2] doComputeSelf(
    [vec3, numD] data,
    i32 numBins,
    i32 numBins2,
    [f32, numBBins] binb
) =
-- loop version
    let value = map(fn [i64, numBins2] (vec3 vec, i32 index) =>
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
                        let index = unsafe if dot >= binb[min]
                                    then min
                                    else if dot < binb[max]
                                        then max+1
                                        else max
                        in
                        unsafe let dBins[index] = dBins[index] + 1i64 in dBins
                    in dBins
                , zip(data, iota(numD)))
    in
    sumBins(value)

fun vec3 fixPoints(f32 ra, f32 dec) =
    let rarad = dec2rad(ra)
    let decrad = dec2rad(dec)
    let cd = cos32(decrad)
    in
    (cos32(rarad)*cd, sin32(rarad)*cd, sin32(decrad))

fun *[i64, 60] main(
    [f32,numD] datapointsx,
    [f32, numD] datapointsy,
    [[f32, numR], numRs] randompointsx,
    [[f32, numR], numRs] randompointsy
) =
    let numBins2 = numBins() + 2
    let binb = map(fn f32 (f32 k) =>
                        cos32((10.0 ** (log10(min_arcmin()) + k*1.0/bins_per_dec())) / 60.0 * dec2rad(1.0)),
                    iota32(numBins() + 1))
    let datapoints = map(fixPoints, zip(datapointsx, datapointsy))
    let randompoints = map(fn [vec3, numR] ([f32, numR] x, [f32, numR] y) =>
                            map(fixPoints, zip(x,y)),
                           zip(randompointsx, randompointsy))
    let (rrs, drs) = unzip(map(fn (*[i64], *[i64]) ([vec3, numR] random) =>
                                (doComputeSelf(random, numBins(), numBins2, binb),
                                doCompute(datapoints, random, numBins(), numBins2, binb)),
                               randompoints))
    loop ((res, dd, rr, dr) = (replicate(numBins()*3, 0i64),
                               doComputeSelf(datapoints, numBins(), numBins2, binb),
                               sumBins(rrs),
                               sumBins(drs))) = for i < numBins() do
        let res[i*3] = dd[i+1]
        let res[i*3+1] = dr[i+1]
        let res[i*3+2] = rr[i+1]
        in
        (res, dd, rr, dr)
    in
    res
