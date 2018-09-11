defmodule BN.PairingTest do
  use ExUnit.Case, async: true

  alias BN.{Pairing, FQ2, BN128Arithmetic, FQ, FQ12}

  describe "twist/1" do
    test "twists fq2 point to fq12" do
      x =
        FQ2.new([
          10_857_046_999_023_057_135_944_570_762_232_829_481_370_756_359_578_518_086_990_519_993_285_655_852_781,
          11_559_732_032_986_387_107_991_004_021_392_285_783_925_812_861_821_192_530_917_403_151_452_391_805_634
        ])

      y =
        FQ2.new([
          8_495_653_923_123_431_417_604_973_247_489_272_438_418_190_587_263_600_148_770_280_649_306_958_101_930,
          4_082_367_875_863_433_681_332_203_403_145_435_568_316_851_327_593_401_208_105_741_076_214_120_093_531
        ])

      {result_x, result_y} = twisted = Pairing.twist({x, y})
      assert BN128Arithmetic.on_curve?(twisted)

      expected_x_coordinates = [
        0,
        0,
        16_260_673_061_341_949_275_257_563_295_988_632_869_519_996_389_676_903_622_179_081_103_440_260_644_990,
        0,
        0,
        0,
        0,
        0,
        11_559_732_032_986_387_107_991_004_021_392_285_783_925_812_861_821_192_530_917_403_151_452_391_805_634,
        0,
        0,
        0
      ]

      expected_y_coordinates = [
        0,
        0,
        0,
        15_530_828_784_031_078_730_107_954_109_694_902_500_959_150_953_518_636_601_196_686_752_670_329_677_317,
        0,
        0,
        0,
        0,
        0,
        4_082_367_875_863_433_681_332_203_403_145_435_568_316_851_327_593_401_208_105_741_076_214_120_093_531,
        0,
        0
      ]

      result_x.coef
      |> Enum.zip(expected_x_coordinates)
      |> Enum.each(fn {result, expected} ->
        assert result.value == expected
      end)

      result_y.coef
      |> Enum.zip(expected_y_coordinates)
      |> Enum.each(fn {result, expected} ->
        assert result.value == expected
      end)
    end
  end

  describe "point_to_fq12/1" do
    test "converts fq point to fq12" do
      x = FQ.new(1)
      y = FQ.new(2)

      point = {x, y}

      {result_x, result_y} = Pairing.point_to_fq12(point)

      expected_x = [x.value] ++ List.duplicate(0, 11)
      expected_y = [y.value] ++ List.duplicate(0, 11)

      result_y.coef
      |> Enum.zip(expected_y)
      |> Enum.each(fn {result, expected} ->
        assert result.value == expected
      end)

      result_x.coef
      |> Enum.zip(expected_x)
      |> Enum.each(fn {result, expected} ->
        assert result.value == expected
      end)
    end
  end

  describe "linefunc/3" do
    test "calculates linefunc when x1 != x2" do
      p1 = FQ12.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
      p2 = FQ12.new([12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1])
      p3 = FQ12.new([13, 11, 14, 9, 15, 7, 16, 5, 17, 3, 18, 1])

      result = Pairing.linefunc({p1, p2}, {p2, p1}, {p1, p3})

      expected_coef = [
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_582,
        0,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_579,
        0,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_576,
        0,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_573,
        0,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_570,
        0,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_567,
        0
      ]

      result.coef
      |> Enum.zip(expected_coef)
      |> Enum.each(fn {coef, expected_coef} ->
        assert coef.value == expected_coef
      end)
    end

    test "calculates linefunc y1 == y2 and x1 == x2" do
      p1 = FQ12.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
      p2 = FQ12.new([12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1])
      p3 = FQ12.new([13, 11, 14, 9, 15, 7, 16, 5, 17, 3, 18, 1])

      result = Pairing.linefunc({p1, p2}, {p1, p2}, {p3, p1})

      expected_coef = [
        10_439_819_245_746_058_310_313_139_969_226_061_548_970_476_147_158_647_771_098_738_126_702_333_288_275,
        20_209_404_315_088_719_024_841_530_023_757_577_221_442_916_246_032_402_603_258_361_507_763_482_253_162,
        12_346_372_785_895_294_661_265_089_133_498_259_359_206_211_902_853_270_591_222_555_012_989_783_273_409,
        2_225_949_448_694_393_910_323_213_160_885_342_166_609_117_239_857_361_263_817_155_735_873_184_227_290,
        1_008_067_730_844_933_359_113_054_255_808_931_466_124_300_546_394_395_826_984_240_453_108_152_353_012,
        1_516_942_216_910_094_500_825_677_140_438_427_902_429_013_157_462_733_458_399_541_855_718_650_079_595,
        6_647_565_859_822_248_904_845_691_622_828_760_372_493_963_343_068_101_090_943_212_059_771_518_732_195,
        14_348_296_554_621_135_026_490_916_084_855_868_703_774_715_276_346_835_440_457_034_247_597_470_726_033,
        4_131_988_055_083_387_420_506_270_590_737_430_569_941_191_239_276_969_689_261_337_862_956_652_002_638,
        12_981_559_915_505_427_312_266_664_825_518_739_490_323_518_080_894_450_175_819_535_981_262_227_909_672,
        21_620_666_551_060_808_402_579_464_748_019_593_623_087_397_264_480_253_713_385_718_524_557_823_081_709,
        14_538_267_961_174_646_047_764_412_186_200_994_980_531_811_546_992_611_290_073_169_580_161_654_554_253
      ]

      result.coef
      |> Enum.zip(expected_coef)
      |> Enum.each(fn {coef, expected_coef} ->
        assert coef.value == expected_coef
      end)
    end

    test "calculates linefunc when x1 == x2 and y1 != y2" do
      p1 = FQ12.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
      p2 = FQ12.new([12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1])
      p3 = FQ12.new([13, 11, 14, 9, 15, 7, 16, 5, 17, 3, 18, 1])

      result = Pairing.linefunc({p1, p2}, {p1, p3}, {p2, p3})

      expected_coef = [
        11,
        9,
        7,
        5,
        3,
        1,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_582,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_580,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_578,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_576,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_574,
        21_888_242_871_839_275_222_246_405_745_257_275_088_696_311_157_297_823_662_689_037_894_645_226_208_572
      ]

      result.coef
      |> Enum.zip(expected_coef)
      |> Enum.each(fn {coef, expected_coef} ->
        assert coef.value == expected_coef
      end)
    end
  end

  describe "miller_loop/2" do
    test "calculates result of miller loop" do
      p1 = FQ12.new([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
      p2 = FQ12.new([12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1])
      p3 = FQ12.new([13, 11, 14, 9, 15, 7, 16, 5, 17, 3, 18, 1])
      p4 = FQ12.new([15, 21, 35, 29, 43, 7, 16, 5, 17, 11, 18, 1])

      point1 = {p1, p4}
      point2 = {p2, p3}

      result = Pairing.miller_loop(point1, point2)

      expected_result = [
        1_012_335_139_722_345_272_338_123_710_341_390_911_023_671_687_282_184_010_688_634_879_214_088_507_391,
        13_938_496_302_835_512_258_220_030_642_599_427_134_339_092_844_036_946_994_286_471_582_871_445_091_227,
        12_693_754_278_262_565_808_015_314_263_131_936_521_749_196_226_848_333_477_201_386_473_166_307_814_969,
        3_686_109_871_274_696_170_585_806_596_175_897_294_472_066_881_961_238_807_004_915_548_899_355_227_195,
        13_844_837_832_013_398_512_634_119_234_610_103_363_572_739_265_035_929_225_415_654_471_674_574_726_815,
        21_338_715_181_163_683_070_166_631_046_495_335_790_694_084_212_206_767_112_173_968_727_780_465_989_805,
        10_922_316_910_825_793_034_738_077_200_513_816_697_885_248_544_620_552_344_189_415_034_632_102_817_894,
        4_937_801_530_440_037_840_052_981_291_487_808_939_016_032_375_030_546_554_710_469_448_707_952_014_993,
        20_176_512_526_894_641_983_987_554_706_433_352_698_824_792_899_238_700_296_859_196_863_806_462_379_469,
        5_175_449_848_872_256_314_485_702_048_544_675_972_423_304_933_364_976_641_223_343_384_536_360_140_960,
        20_241_485_405_010_264_455_232_789_923_488_864_579_892_603_982_247_431_495_624_175_666_954_765_111_951,
        11_313_716_254_294_910_799_735_212_239_819_919_957_621_813_327_924_783_894_698_664_398_423_496_839_594
      ]

      result.coef
      |> Enum.zip(expected_result)
      |> Enum.each(fn {coef, expected_coef} ->
        assert coef.value == expected_coef
      end)
    end
  end

  describe "pairing/2" do
    test "calculates pairing result" do
      x1 =
        FQ2.new([
          10_857_046_999_023_057_135_944_570_762_232_829_481_370_756_359_578_518_086_990_519_993_285_655_852_781,
          11_559_732_032_986_387_107_991_004_021_392_285_783_925_812_861_821_192_530_917_403_151_452_391_805_634
        ])

      y1 =
        FQ2.new([
          8_495_653_923_123_431_417_604_973_247_489_272_438_418_190_587_263_600_148_770_280_649_306_958_101_930,
          4_082_367_875_863_433_681_332_203_403_145_435_568_316_851_327_593_401_208_105_741_076_214_120_093_531
        ])

      point1 = {x1, y1}
      point2 = {FQ.new(1), FQ.new(2)}

      result = Pairing.pairing(point1, point2)

      expected_result = [
        18_443_897_754_565_973_717_256_850_119_554_731_228_214_108_935_025_491_924_036_055_734_000_366_132_575,
        10_734_401_203_193_558_706_037_776_473_742_910_696_504_851_986_739_882_094_082_017_010_340_198_538_454,
        5_985_796_159_921_227_033_560_968_606_339_653_189_163_760_772_067_273_492_369_082_490_994_528_765_680,
        4_093_294_155_816_392_700_623_820_137_842_432_921_872_230_622_290_337_094_591_654_151_434_545_306_688,
        642_121_370_160_833_232_766_181_493_494_955_044_074_321_385_528_883_791_668_868_426_879_070_103_434,
        4_527_449_849_947_601_357_037_044_178_952_942_489_926_487_071_653_896_435_602_814_872_334_098_625_391,
        3_758_435_817_766_288_188_804_561_253_838_670_030_762_970_764_366_672_594_784_247_447_067_868_088_068,
        18_059_168_546_148_152_671_857_026_372_711_724_379_319_778_306_792_011_146_784_665_080_987_064_164_612,
        14_656_606_573_936_501_743_457_633_041_048_024_656_612_227_301_473_084_805_627_390_748_872_617_280_984,
        17_918_828_665_069_491_344_039_743_589_118_342_552_553_375_221_610_735_811_112_289_083_834_142_789_347,
        19_455_424_343_576_886_430_889_849_773_367_397_946_457_449_073_528_455_097_210_946_839_000_147_698_372,
        7_484_542_354_754_424_633_621_663_080_190_936_924_481_536_615_300_815_203_692_506_276_894_207_018_007
      ]

      result.coef
      |> Enum.zip(expected_result)
      |> Enum.each(fn {coef, expected_coef} ->
        assert coef.value == expected_coef
      end)
    end
  end
end