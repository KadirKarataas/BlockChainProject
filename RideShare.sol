// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Rideshare {
    uint256 public rideId;
    // ride'ın yapısı
    struct Ride {
        address payable rider;
        address payable driver;
        uint256 price;
        uint256 distance;
        uint256 cashBack;
        bool isCompleted;
    }

    mapping(uint256 => Ride) public rides;

    event NewRide(uint256 rideId, address indexed rider, address indexed driver);

    constructor() payable {
        require(msg.value >= 0.0001 ether, "Minimum deployment cost is 0.0001 ether");
    }
    // Function to request a ride
    function requestRide(address payable _driver, uint256 _distance) external payable {
        require(msg.value >= _distance * 0.001 ether, "Insufficient funds for ride");

        uint256 _price = msg.value;
        uint256 _cashBack = _price - (_distance * 0.001 ether);

        rides[rideId] = Ride(payable(msg.sender), _driver, _price, _distance, _cashBack, false);

        emit NewRide(rideId, msg.sender, _driver);
        rideId++;
    }
    
    //sürücünün kabul etme fonksiyonu
    function acceptRide(uint256 _rideId) external {
        Ride storage ride = rides[_rideId];
        require(msg.sender == ride.driver, "Only assigned driver can accept the ride");

        payable(ride.rider).transfer(ride.cashBack);
    }
    // iptal etme fonksiyonu sürücü ve yolcu iptal edebilir
    function cancelRide(uint256 _rideId) external {
        Ride storage ride = rides[_rideId];
        require(msg.sender == ride.rider || msg.sender == ride.driver, "Only rider or driver can cancel");

        payable(ride.rider).transfer(ride.price);
        delete rides[_rideId];
    }
    // yolcu tarafından gerçekleştirilecek yolculuk tamamlandı fonksiyonu
    function rideCompleted(uint256 _rideId) external {
        Ride storage ride = rides[_rideId];
        require(msg.sender == ride.rider, "Only rider can mark as completed");
        require(!ride.isCompleted, "Ride already completed");

        ride.isCompleted = true;
        payable(ride.driver).transfer(ride.price);
    }
}
