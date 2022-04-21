pragma solidity ^0.8.13;
//SPDX-License-Identifier: UNLICENSED

contract MyContract 
{

    enum State{Default, Confirmed, Claimed, Done}
    State constant defaultChoice = State.Default;


    struct Bet
    {
        address p1;
        address p2;
        State betState;
        bytes32 message;
        uint val;
        uint tentativewinner;
    }
    //array of all bets(active and inactive) maybe change this?
    Bet[] bets;
    function requestBet(bytes32 _msg, address _to) public payable
    {
        //value = msg.value
        //person1 = msg.sender
        bets.push(Bet(msg.sender, _to, State.Default, _msg, uint(msg.value), 0));
    }

    function acceptBet(uint _betId) public payable
    {   
        Bet storage bet = bets[_betId];
        if(bet.p2 != msg.sender || msg.value != bet.val || bet.betState!=State.Default)
        {
            revert();
        }
        bet.betState = State.Confirmed;
    }

    function rejectBet(uint _betId) public 
    {   
        Bet storage bet = bets[_betId];
        require(bet.p2 == msg.sender && bet.betState==State.Default);
        
        bet.betState = State.Done;
        // pay p1 back
        //https://ethereum.stackexchange.com/questions/94707/how-to-fix-typeerror-type-address-is-not-implicitly-convertible-to-expected-ty
        payable(bet.p1).transfer(bet.val);
    }

    function forfeit(uint _betId) public
    {
        Bet storage bet = bets[_betId];
        require((bet.p1==msg.sender || bet.p2==msg.sender)&& (bet.betState==State.Confirmed || bet.betState==State.Default));
        bet.betState = State.Done;
        payable(bet.p1).transfer(bet.val);
        payable(bet.p2).transfer(bet.val);
    }
    function claim(uint _betId) public 
    {
        Bet storage bet = bets[_betId];
        require((bet.p1==msg.sender || bet.p2==msg.sender)&& bet.betState==State.Confirmed);
        bet.betState=State.Claimed;

        if(msg.sender == bet.p1) bet.tentativewinner=1;
        else bet.tentativewinner = 2;
    }

    function confirm(uint _betId) public
    {
        Bet storage bet = bets[_betId];
        require(((msg.sender==bet.p1&&bet.tentativewinner==2)||(msg.sender==bet.p2&&bet.tentativewinner==1)) && bet.betState==State.Claimed);

        bet.betState = State.Done;
        address _to;
        if(bet.tentativewinner==1)_to = bet.p1;
        else _to = bet.p2;

        payable(_to).transfer(bet.val*2);
    }
    
    function deny(uint _betId) public
    {
        Bet storage bet = bets[_betId];
        require(((msg.sender==bet.p1&&bet.tentativewinner==2)||(msg.sender==bet.p2&&bet.tentativewinner==1)) && bet.betState==State.Claimed);
        bet.betState = State.Confirmed;
    }


}



/*
Handle the string case
Don't make request bet payable, only pay once 
Bets array bad idea?
simultaneous payment somehow
notification problem
expiration to the requests
expiration to the bets

*/
