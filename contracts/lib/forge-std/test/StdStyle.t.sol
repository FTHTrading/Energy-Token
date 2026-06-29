// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.8.13 <0.9.0;

import {Test, console2, StdStyle} from "../src/Test.sol";

contract StdStyleTest is Test {
    function test_StyleColor() public pure {
        console2.log(StdStyle.red("StdStyle.red"));
        console2.log(StdStyle.green("StdStyle.green"));
        console2.log(StdStyle.yellow("StdStyle.yellow"));
        console2.log(StdStyle.blue("StdStyle.blue"));
        console2.log(StdStyle.magenta("StdStyle.magenta"));
        console2.log(StdStyle.cyan("StdStyle.cyan"));
        console2.log(StdStyle.bold("StdStyle.bold"));
        console2.log(StdStyle.dim("StdStyle.dim"));
        console2.log(StdStyle.italic("StdStyle.italic"));
        console2.log(StdStyle.underline("StdStyle.underline"));
        console2.log(StdStyle.inverse("StdStyle.inverse"));
    }

    function test_StyleColorForUint() public pure {
        console2.log(StdStyle.red(123));
        console2.log(StdStyle.green(123));
        console2.log(StdStyle.yellow(123));
        console2.log(StdStyle.blue(123));
        console2.log(StdStyle.magenta(123));
        console2.log(StdStyle.cyan(123));
    }

    function test_StyleColorForInt() public pure {
        console2.log(StdStyle.red(int256(123)));
        console2.log(StdStyle.green(int256(123)));
        console2.log(StdStyle.yellow(int256(123)));
        console2.log(StdStyle.blue(int256(123)));
        console2.log(StdStyle.magenta(int256(123)));
        console2.log(StdStyle.cyan(int256(123)));
    }

    function test_StyleColorForAddress() public pure {
        console2.log(StdStyle.red(address(0)));
        console2.log(StdStyle.green(address(0)));
        console2.log(StdStyle.yellow(address(0)));
        console2.log(StdStyle.blue(address(0)));
        console2.log(StdStyle.magenta(address(0)));
        console2.log(StdStyle.cyan(address(0)));
    }

    function test_StyleColorForBool() public pure {
        console2.log(StdStyle.red(true));
        console2.log(StdStyle.green(true));
        console2.log(StdStyle.yellow(true));
        console2.log(StdStyle.blue(true));
        console2.log(StdStyle.magenta(true));
        console2.log(StdStyle.cyan(true));
    }

    function test_StyleColorForBytes() public pure {
        console2.log(StdStyle.redBytes(hex"abcd"));
        console2.log(StdStyle.greenBytes(hex"abcd"));
        console2.log(StdStyle.yellowBytes(hex"abcd"));
        console2.log(StdStyle.blueBytes(hex"abcd"));
        console2.log(StdStyle.magentaBytes(hex"abcd"));
        console2.log(StdStyle.cyanBytes(hex"abcd"));
    }

    function test_StyleColorForBytes32() public pure {
        console2.log(StdStyle.redBytes32(bytes32(hex"abcd")));
        console2.log(StdStyle.greenBytes32(bytes32(hex"abcd")));
        console2.log(StdStyle.yellowBytes32(bytes32(hex"abcd")));
        console2.log(StdStyle.blueBytes32(bytes32(hex"abcd")));
        console2.log(StdStyle.magentaBytes32(bytes32(hex"abcd")));
        console2.log(StdStyle.cyanBytes32(bytes32(hex"abcd")));
    }

    function test_StyleCustom() public pure {
        string memory customStyle = StdStyle.custom("\u001b[38;5;208m");
        console2.log(customStyle("StdStyle.custom"));
    }

    function test_StyleCustomForUint() public pure {
        string memory customStyle = StdStyle.custom("\u001b[38;5;208m");
        console2.log(customStyle(123));
    }

    function test_StyleCustomForInt() public pure {
        string memory customStyle = StdStyle.custom("\u001b[38;5;208m");
        console2.log(customStyle(int256(123)));
    }

    function test_StyleCustomForAddress() public pure {
        string memory customStyle = StdStyle.custom("\u001b[38;5;208m");
        console2.log(customStyle(address(0)));
    }

    function test_StyleCustomForBool() public pure {
        string memory customStyle = StdStyle.custom("\u001b[38;5;208m");
        console2.log(customStyle(true));
    }

    function test_StyleCustomForBytes() public pure {
        string memory customStyle = StdStyle.custom("\u001b[38;5;208m");
        console2.log(customStyle(hex"abcd"));
    }

    function test_StyleCustomForBytes32() public pure {
        string memory customStyle = StdStyle.custom("\u001b[38;5;208m");
        console2.log(customStyle(bytes32(hex"abcd")));
    }

    function test_StyleComposite() public pure {
        string memory compositeStyle = StdStyle.composite(StdStyle.red, StdStyle.bold);
        console2.log(compositeStyle("StdStyle.composite"));
    }

    function test_StyleCompositeForUint() public pure {
        string memory compositeStyle = StdStyle.composite(StdStyle.red, StdStyle.bold);
        console2.log(compositeStyle(123));
    }

    function test_StyleCompositeForInt() public pure {
        string memory compositeStyle = StdStyle.composite(StdStyle.red, StdStyle.bold);
        console2.log(compositeStyle(int256(123)));
    }

    function test_StyleCompositeForAddress() public pure {
        string memory compositeStyle = StdStyle.composite(StdStyle.red, StdStyle.bold);
        console2.log(compositeStyle(address(0)));
    }

    function test_StyleCompositeForBool() public pure {
        string memory compositeStyle = StdStyle.composite(StdStyle.red, StdStyle.bold);
        console2.log(compositeStyle(true));
    }

    function test_StyleCompositeForBytes() public pure {
        string memory compositeStyle = StdStyle.composite(StdStyle.red, StdStyle.bold);
        console2.log(compositeStyle(hex"abcd"));
    }

    function test_StyleCompositeForBytes32() public pure {
        string memory compositeStyle = StdStyle.composite(StdStyle.red, StdStyle.bold);
        console2.log(compositeStyle(bytes32(hex"abcd")));
    }
}
