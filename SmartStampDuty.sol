pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}

/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseAllowance(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseAllowance(spender, subtractedValue);
  }
}

/**
 * @title StampDuty
 * @dev A new class for stamp duty called StampDuty
 * @dev 
 */
contract StampDuty is Ownable, ERC20Pausable {
    /**
    * @dev zeroAddress can be used to burn tokens that have been received and audited.
    * @param zeroAddress is unusable
    */    
    address constant public zeroAddress = 0x0000000000000000000000000000000000000000;
    
    /**
    * @dev Referential Integrity check https://medium.com/@robhitchens/enforcing-referential-integrity-in-ethereum-smart-contracts-a9ab1427ff42
    * @dev StampParam contains system parameters
    * @dev StampParam can only be modified by owner
    * @param StampCode is the unique code for the stamp and the primary key.
    * @param StampName is the name of the stamp in human readable format
    * @param StampPrice is the price of the stamp, in integer
    * @param RegulationReference is the reference to a specific tax regulation
    * @param StampIndex is the index or position of the data
    */  
    struct StampParam {
        bytes32 StampCode;
        string StampName;
        uint32 StampPrice;
        string RegulationReference;
        uint StampIndex;
        bool IsActive;
        /**
         * @dev To support deletion and keeps the referential integrity
         * @param PayParamDocHash is to refer to Document hash
         * @param PayIndexPointers refers to the payment details
        */
        bytes32[] PayCode;
        mapping (bytes32 => uint256) PayIndexPointers;
    }
    /**
     * @param StampStructs is for indexing based on StampName
     * @param StampList is for sequential access based on StampCode to get the stamp row data
    */
    mapping (bytes32 => StampParam) StampStructs;
    bytes32[] StampList;
    
    /**
    * @dev PayParam is to store payment detail
    * @param PayCode is the payment code generated by the system. It can be a hash of document hash, payer address, and timestamp. This is the primary key and unique.
    * @param DocHash is the hash value of the document. DocHash is not unique.
    * @param PayIndex is the index of the payment
    * @param Payer is the address of the Payer
    * @param StampIndex refers to the StampParam
    * @param BloomFilter is used to test the similarity between the original document (hashed one) and the claimed document (printed or electronic document)
    */ 
    struct PayParam {
        bytes32 PayCode;
        string DocHash;
        uint256 PayIndex;
        address Payer;
        bytes32 StampCode;
        string BloomFilter;
    }
    
    mapping (bytes32 => PayParam) PayStructs;
    bytes32[] PayList;
    
    /**
     * @dev getStampCount counts the number of stamp types
     */
    function getStampCount() public constant returns (uint stampCount) {
        return StampList.length;
    }
    
    /**
     * @dev getStampList returns StampList
     */
    function getStampList() public constant returns (bytes32[]) {
        return StampList;
    }
    
    /**
     * @dev getStampPayCodes returns PayCode array
     * @dev can be used to list all payments of a stamp, determined by stampCode
     */
    function getStampPayCodes(bytes32 stampCode) public constant returns (bytes32[]) {
        return StampStructs[stampCode].PayCode;
    }
    
    /**
     * @dev getStampDetail gets the detail of stamp data based on StampCode
     * @dev reference: https://medium.com/coinmonks/solidity-tutorial-returning-structs-from-public-functions-e78e48efb378
     * @dev returns the structure of StampParam
     */
    function getStampDetail(bytes32 stampCode) public constant returns (bytes32 StampCode, string StampName, uint32 StampPrice, 
        string RegulationReference, uint StampIndex, bool isActive) {
        StampParam memory s = StampStructs[stampCode];
        return (s.StampCode, s.StampName, s.StampPrice, s.RegulationReference, s.StampIndex, s.IsActive);
    }
    
    /**
     * @dev getStampDetailByIndex gets the detail of stamp data based on its index
     * @dev reference: https://medium.com/coinmonks/solidity-tutorial-returning-structs-from-public-functions-e78e48efb378
     * @dev returns the structure of StampParam
     */
    function getStampDetailByIndex(uint stampIndex) public constant returns (bytes32 StampCode, string StampName, uint32 StampPrice, 
        string RegulationReference, uint StampIndex, bool isActive) {
        // get the StampCode first
        bytes32 stampCode = StampList[stampIndex];
        StampParam memory s = StampStructs[stampCode];
        return (s.StampCode, s.StampName, s.StampPrice, s.RegulationReference, s.StampIndex, s.IsActive);
    }
    
    /**
     * @dev stampActivate activates the stamp described by stampCode
     * @dev onlyOwner
     */
    function stampActivate(bytes32 stampCode) public onlyOwner returns (bool success) {
        // check if it is a valid stamp
        require(isStamp(stampCode));
        // check if stamp is currently deactivated
        require(StampStructs[stampCode].IsActive == false);
        StampStructs[stampCode].IsActive = true;
        return true;
    }
    
    /**
     * @dev stampDeactivate deactivates the stamp described by stampCode
     * @dev onlyOwner
     */
    function stampDeactivate(bytes32 stampCode) public onlyOwner returns (bool success) {
        // check if it is a valid stamp
        require(isStamp(stampCode));
        // check if stamp is currently activated
        require(StampStructs[stampCode].IsActive == true);
        StampStructs[stampCode].IsActive = false;
        return true;
    }
    
    /**
     * @dev getPaymentCount counts the number of payments
     */
    function getPaymentCount() public constant returns (uint paymentCount) {
        return PayList.length;
    }
    
    /**
     * @dev getPayList returns PayList array
     */
    function getPayList() public constant returns (bytes32[]) {
        return PayList;
    }
    
    /**
     * @dev getPaymentDetail gets the detail of payment data based on PayCode
     * @dev reference: https://medium.com/coinmonks/solidity-tutorial-returning-structs-from-public-functions-e78e48efb378
     * @dev returns the structure of PayParam
     */
    function getPaymentDetail(bytes32 payCode) public constant returns (bytes32 PayCode, string DocHash, uint256 PayIndex, 
        address Payer, bytes32 StampCode, string BloomFilter) {
        PayParam memory p = PayStructs[payCode];
        return (p.PayCode, p.DocHash, p.PayIndex, p.Payer, p.StampCode, p.BloomFilter);
    }
    
    /**
     * @dev isStamp checks if the stamp is valid
     */
    function isStamp (bytes32 stampCode) public constant returns (bool isIndeed) {
        if (StampList.length == 0) return false;
        return StampList[StampStructs[stampCode].StampIndex] == stampCode;
    }
    
    /**
     * @dev isPayment checks if a particular payment code exists
     */
    function isPayment (bytes32 payCode) public constant returns (bool isIndeed) {
        if (PayList.length == 0) return false;
        return PayList[PayStructs[payCode].PayIndex] == payCode;
    }
    
    /**
     * @dev getPaymentOfStampCount counts payments based on a specific StampName
     */
    function getPaymentOfStampCount(bytes32 stampCode) public constant returns (uint paymentOfStampCount) {
        //deprecated if(!isStamp(StampName)) throw;
        require(isStamp(stampCode));
        return StampStructs[stampCode].PayCode.length;
    }
    
    /**
     * @dev getPaymentOfStampAtIndex payments based on a specific StampName
     */
    function getPaymentOfStampAtIndex(bytes32 stampCode, uint row) public constant returns (bytes32 paymentCode) {
        require(isStamp(stampCode));
        return StampStructs[stampCode].PayCode[row];
    }
    
    /**
     * @dev createStamp creates a new stamp, only owner can do this
     */
    function createStamp(bytes32 stampCode, string stampName, uint32 stampPrice, string regulationReference, bool isActive) public onlyOwner returns (bool success) {
        //prevent duplicate
        require(!isStamp(stampCode));
        //add new data
        /**
        bytes32 StampCode;
        string StampName;
        uint32 StampPrice;
        string RegulationReference;
        uint StampIndex;
         */
        StampStructs[stampCode].StampCode = stampCode;
        StampStructs[stampCode].StampName = stampName;
        StampStructs[stampCode].StampPrice = stampPrice;
        StampStructs[stampCode].RegulationReference = regulationReference;
        StampStructs[stampCode].StampIndex = StampList.push(stampCode) - 1;
        StampStructs[stampCode].IsActive = isActive;
        
        /**
         * @Todo should add Event here
         */
        return true;
    }
    
    /**
     * @dev createPayment creates a new payment
     */
    function createPayment(bytes32 payCode, string docHash, bytes32 stampCode, string bloomFilter) public returns (bool success) {
        //prevent duplicate
        require(!isPayment(payCode));
        //check referential integrity for stampCode
        require(isStamp(stampCode));
        //stamp needs to be active
        require(StampStructs[stampCode].IsActive == true);
        //check payCode cannot empty
        require(payCode.length > 0);
        //check dochHash cannot empty
        bytes memory tempDocHash = bytes(docHash);
        require(tempDocHash.length > 0);
        //require the balance to be enough to pay the stamp price
        require(balanceOf(msg.sender) >= StampStructs[stampCode].StampPrice);
        //pay the stamp duty to the smart contract owner
        transfer(owner(), StampStructs[stampCode].StampPrice);

        /**
        bytes32 PayCode;
        string DocHash;
        uint256 PayIndex;
        address Payer;
        bytes32 StampCode;
        string BloomFilter;
         */
        PayStructs[payCode].PayCode = payCode;
        PayStructs[payCode].DocHash = docHash;
        PayStructs[payCode].PayIndex = PayList.push(payCode) - 1;
        PayStructs[payCode].Payer = msg.sender;
        PayStructs[payCode].StampCode = stampCode;
        PayStructs[payCode].BloomFilter = bloomFilter;
        
        //maintain new payment in Stamp data
        StampStructs[stampCode].PayIndexPointers[payCode] = StampStructs[stampCode].PayCode.push(payCode) - 1;
        /**
         * @Todo should add Event here
         */
        return true;
    }
    
    /**
     * @Todo create functions to modify and delete stamp
     * @Todo modify and delete payment might not be needed
     */
    
    
    /**
     * @dev A function to burn tokens to constant address zeroAddress.
     */
    function _burnToZeroAddress(uint256 value) public onlyOwner returns (bool) {
    _transfer(msg.sender, zeroAddress, value);
    return true;
  }
    
}

/**
 * @title Smart Stamp Duty Token
 * @dev ERC20 Tokens
 */
contract SmartStampDuty is StampDuty {

  string public constant name = "Smart Stamp Duty";
  string public constant symbol = "SSD";
  uint8 public constant decimals = 0;

  /**
   * @dev Initial supply will be  10 trillion or 10*10**12
   * @dev Each SSD represents 1 Rupiah, hence the total amount of SSD received represents tax money
   * @dev The number of available SSD can be increased further by mint function
   * @dev No decimal is required
   */ 
  uint256 public constant INITIAL_SUPPLY = 10*10**12 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  constructor() public {
    _mint(msg.sender, INITIAL_SUPPLY);
  }


  /**
   * @dev Enable minting
   */ 
  function mint(address account, uint256 value) public {
    _mint(account, value);
  }
  
  /**
   * @dev Enable send coins to zeroAddress
   */ 
  function burnToZeroAddress(uint256 value) public {
    _burnToZeroAddress(value);
  }

}
