//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
    mapping(address => uint256) public foo;
    //foo[address] = uint256
*/

/*
payable function
>> 이 함수를 호출시킬때 컨트랙트에다가 이더리움을 보낼수 있음
>> 함수를 실행시킬때 이더리움이 필요한 함수에만 사용
payable address
payable(address) 로 감싸주면 그 어드레스에 이더리움을 보낼 수 있음(컨트랙트가)
결론 : payable은 이더리움 전송에만 쓴다 // 이더리움 전송하는거 아니면 생각도 하지 말것
*/

/*
address[] depositor
depositor 라는 친구는 address들의 배열이구나!
선언 address[10] = 0x1234546545364565465656;
아 address의 10번 친구는 0x1234546545364565465656 이구나!  xxxxxxxxxxxxxxxxxxxxxx
address의 10번 친구는 어떤 메모리에 넣어야 하지???? 모르겠네 oooooooooooooooooooooo
지정된 칸
address[] depositor;
address[20] = 0x123234;
ㅁㅁㅁㅁㅁㅁㅁㅁㅁㅁㅁㅁㅁㅁㅁㅁㅁㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅛㅛㅛ0x123234ㅛㅛㅛㅛㅛㅛㅎㅎㅎㅎㅎㅎㅎㅁㅁㅁㅁ
address[10] == 0x1234546545364565465656
*/


// 이더리움에서 내 주소를 검색하면 >> 나는 erc20 토큰을 어떤것을 얼마나 가지고있는지 모른다
// 그럼 어떻게 아냐
// A 토큰 컨트랙트에 가서 내 주소를 입력하면 A 토큰 컨트랙트에 기록된 내가 가지고 있는 양을 알수 있음
// B 토큰 컨트랙트에 가서 입력 > 내가 B를 얼마나 가지고있는지 알수 있음
// C 도 마찬가지


// solidity는 소수점 지원 안함
// decimal == 18 이기 때문에 0을 18개 붙이면 1개
// 1000000000000000000 로 입력해서 1개 받음

contract A is ERC20 { // A는 그냥 토큰
    constructor(uint256 initialSupply) ERC20(unicode"tokenTest2", unicode"TST2") {
        _mint(msg.sender, initialSupply);
    }
}

contract B { // B는 그냥 창고
    event Deposit(address, uint256);
    event Withdraw(address, uint256);

    address internal immutable yourToken;

    mapping(address => uint256) public _deposit;

    constructor(address token) {
        yourToken = token;
    }

// approve먼저 공부, 심화 숙제 : 혼자쓰는거 말고 누구나 쓸수있는 창고
    function deposit(uint256 amount) public {
        _deposit[msg.sender] += amount;
        ERC20(yourToken).transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(_deposit[msg.sender] >= amount, "test");
        
        _deposit[msg.sender] -= amount;
        ERC20(yourToken).transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }
}

contract C {
    uint256 public number;

    constructor(uint256 val) {
        number = val;
    }

// 값을 읽어서 쓰면 view
    function foo(uint256 a, uint256 b) public view returns (uint256) {
        return (number + a + b);
    }

// 읽는것 없으면 pure
    function bar(uint256 a, uint256 b) public pure returns (uint256) {
        return (a + b);
    }
}