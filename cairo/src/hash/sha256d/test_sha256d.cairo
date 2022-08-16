#
# To run only this test suite use:
# protostar test --cairo-path=./src target src/**/*_sha256d*
#
%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

from tests.utils_for_testing import setup_python_defs
from hash.sha256d.sha256d import _compute_double_sha256, sha256d, assert_hashes_equal, HASH_FELT_SIZE


@external
func test_compute_double_sha256{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals

    # Set input to "abc"
    let (input) = alloc()
    assert input[0] = 0x61626300
    let byte_size = 3
    
    let (hash) = sha256d(input, byte_size)
    # 8cb9012517c817fead650287d61bdd9c68803b6bf9c64133dcab3e65b5a50cb9
    assert hash[0] = 0x4f8b42c2
    assert hash[1] = 0x2dd3729b
    assert hash[2] = 0x519ba6f6
    assert hash[3] = 0x8d2da7cc
    assert hash[4] = 0x5b2d606d
    assert hash[5] = 0x05daed5a
    assert hash[6] = 0xd5128cc0
    assert hash[7] = 0x3e6c6358

    return () 
end

# Test a double sha256 input with a long byte string 
# (We use a 259 bytes transaction here)
#
# See also:
#  - Example Transaction: https://blockstream.info/api/tx/b9818f9eb8925f2b5b9aaf3e804306efa1a0682a7173c0b7edb5f2e05cc435bd/hex 
@external
func test_sha256d_long_input{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals

    # Use Python to convert hex string into uint32 array
    let (input) = alloc()
    local byte_size
    let (hash_expected) = alloc()

    setup_python_defs()
   %{
    ids.byte_size = from_hex((
        "0100000001352a68f58c6e69fa632a1bf77566cf83a7515fc9ecd251fa37f410"
        "460d07fb0c010000008c493046022100e30fea4f598a32ea10cd56118552090c"
        "be79f0b1a0c63a4921d2399c9ec14ffc022100ef00f238218864a909db55be9e"
        "2e464ccdd0c42d645957ea80fa92441e90b4c6014104b01cf49815496b5ef83a"
        "bd1a3891996233f0047ada682d56687dd58feb39e969409ce70be398cf73634f"
        "f9d1aae79ac2be2b1348ce622dddb974ad790b4106deffffffff02e093040000"
        "0000001976a914a18cc6dd0e38dea210390a2403622ffc09dae88688ac8152b5"
        "00000000001976a914d73441c86ea086121991877e204516f1861c194188ac00"
        "000000"), ids.input)

    hashes_from_hex([
        "b9818f9eb8925f2b5b9aaf3e804306efa1a0682a7173c0b7edb5f2e05cc435bd"
        ], ids.hash_expected)
    %}

    let (hash) = sha256d(input, byte_size)

    assert_hashes_equal(hash_expected, hash)
    return () 
end


# Test a double sha256 input with a 64-byte subarray of a 67-byte array
@external
func test_sha256d_64bytes_input{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals

    # Use Python to convert hex string into uint32 array
    let (input) = alloc()
    setup_python_defs()
   %{
    from_hex((
        "0100000001352a68f58c6e69fa632a1bf77566cf83a7515fc9ecd251fa37f410"
        "460d07fb0c010000008c493046022100e30fea4f598a32ea10cd56118552090c"
        "be79f0"
    ), ids.input)
    %}

    # Hash only 64 bytes of the input
    let (hash) = sha256d(input, 64)

    return () 
end