//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
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

contract ERC20_A is ERC20 { // ERC20 토큰
    constructor(uint256 initialSupply) ERC20(unicode"tokenTest1", unicode"TST1") {
        _mint(msg.sender, initialSupply);
    }
}

contract ERC20_B is ERC20 { // ERC20 토큰
    constructor(uint256 initialSupply) ERC20(unicode"tokenTest2", unicode"TST2") {
        _mint(msg.sender, initialSupply);
    }
}

contract ERC721_A is ERC721 { // ERC721 토큰
    mapping(uint256 => string) _tokenUri;

    constructor() ERC721("Test NFT", "TNFT") {}

    function mint(address _to, uint256 _tokenId) external {
        super._mint(_to, _tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        return _tokenUri[tokenId];
    }

    // 권한 설정했다고 가정
    function setUri(string memory uri, uint256 tokenId) public {
        _tokenUri[tokenId] = uri;
    }
}

contract ERC1155_A is ERC1155 {
    uint256 public constant testSet = 0;
    constructor() ERC1155("Test ERC1155") {
        _mint(msg.sender, testSet, 10**3, "");
    }
}

contract market {
    
    mapping(address => uint256) public balance;    // 상품 판매 후 수령할 수 있는 잔액
    mapping(address => mapping(uint256 => bool)) public exist_ERC721;
    mapping(address => mapping(uint256 => uint256)) public _price;                              // 토큰 가격 정보            
    mapping(address => mapping(uint256 => address)) public seller;                              // 판매자 정보

    function sell(address _ERC721, uint256 tokenId, uint256 price) public {
        require(ERC165(_ERC721).supportsInterface(0x80ac58cd)==true);                           // ERC721 토큰인지 확인
            seller[_ERC721][tokenId] = msg.sender;                                              // 판매자 주소 저장
            ERC721(_ERC721).transferFrom(msg.sender, address(this), tokenId);                   // 판매자에게 있는 ERC721 토큰을 market으로 전송            
            _price[_ERC721][tokenId] = price;                                                   // 토큰 가격 등록            
            exist_ERC721[_ERC721][tokenId] = true;
    }

    function buy(address _ERC20, address _ERC721, uint256 tokenId) public {
        require(exist_ERC721[_ERC721][tokenId]==true);                                        // ERC721 토큰이 market에 있어야 함                                  
        ERC721(_ERC721).approve(msg.sender, tokenId);
        ERC20(_ERC20).transferFrom(msg.sender, address(this), _price[_ERC721][tokenId]);      // 구매자의 ERC20 토큰을 market 컨트랙트가 받음
        ERC721(_ERC721).transferFrom(address(this), msg.sender, tokenId);                     // market에 있는 ERC721 토큰을 구매자에게 전송
        
        exist_ERC721[_ERC721][tokenId] = false;
        address _seller = seller[_ERC721][tokenId];                                           
        balance[_seller] += _price[_ERC721][tokenId];                                         // 판매자에게 돌려줘야 할 잔액 증가
    }

    function claim(address _ERC20) public {                                                   // 판매자에게 돌아가야 할 대금 전송
        require(balance[msg.sender] > 0);
        ERC20(_ERC20).approve(msg.sender, balance[msg.sender]);
        ERC20(_ERC20).transferFrom(address(this), msg.sender, balance[msg.sender]);
        balance[msg.sender] = 0;
    }
}



contract C { // 창고
    event Deposit_ERC20(address, uint256);
    event Deposit_ERC721(address, uint256);
    event Withdraw_ERC20(address, uint256);
    event Withdraw_ERC721(address, uint256);
    
    // address yourToken;

    mapping(address => uint256) public _deposit;

    // 유저 >> 토큰ID >> 넣었는지 여부
    mapping(address => mapping(uint256 => bool)) public _depositERC721;

    constructor(){}


    // ERC20 >>> amount
    // ERC721 >>> tokenId
    function deposit(address yourToken, uint256 amountOrTokenId) public {

        uint256 tokenType = typeCheck(yourToken);
        require(tokenType > 0, "typeError");

        if(tokenType == 1) {
            _deposit[msg.sender] += amountOrTokenId;
            ERC20(yourToken).transferFrom(msg.sender, address(this), amountOrTokenId);

            emit Deposit_ERC20(msg.sender, amountOrTokenId);
        } 
        
        if(tokenType == 2) {
            _depositERC721[msg.sender][amountOrTokenId] = true;
            ERC721(yourToken).transferFrom(msg.sender, address(this), amountOrTokenId);
            
            emit Deposit_ERC721(msg.sender, amountOrTokenId);
        }
    }

    function withdraw(address yourToken, uint256 amountOrTokenId) public {
        uint256 tokenType = typeCheck(yourToken);
        require(tokenType > 0, "typeError");
        
        if(tokenType == 1) {
            require(_deposit[msg.sender] >= amountOrTokenId, "test");
            _deposit[msg.sender] -= amountOrTokenId;
            ERC20(yourToken).transfer(msg.sender, amountOrTokenId);

            emit Withdraw_ERC20(msg.sender, amountOrTokenId);
        } 
        
        if(tokenType == 2) {
            require(_depositERC721[msg.sender][amountOrTokenId] == true, "test");
            ERC721(yourToken).transferFrom(address(this), msg.sender, amountOrTokenId);
            _depositERC721[msg.sender][amountOrTokenId] = false;

            emit Withdraw_ERC721(msg.sender, amountOrTokenId);
        }
    }

    // ERC20 : 0
    // ERC721 : 2
    // ERC1155 : 3
    // 그 외 : 0
        function typeCheck(address yourToken) public view returns (uint256) {
            if(ERC165(yourToken).supportsInterface(0xd9b67a26)==true){
                return 3;
            } else if(ERC165(yourToken).supportsInterface(0x80ac58cd)==true) {
                return 2;
            } else {
                return 0;
            }
        }
}
        

    //        function typeCheck(address yourToken) public view returns (uint256) {
    //     try ERC165(yourToken).supportsInterface(0x80ac58cd) returns (bool _isERC721) {
    //         if(_isERC721) {
    //             return 2;
    //         } else {
    //             return 0;
    //         }
    //     } catch {
    //         try ERC165(yourToken).supportsInterface(0xd9b67a26) returns (bool _isERC1155) {
    //             if(_isERC1155) {
    //                 return 3;
    //             }
    //         } catch {
    //             return 0;
    //         }
    //     }
    //     return 0;
    // }


