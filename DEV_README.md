Hello wonderful veil devs!

To start off I would like to apologize in advance for being horrifically unprofessional ;)

I'm making this pull request because one day while I was shamelessly copying your virtual augur shares for my own project I noticed that you were not using
the clone factory optimization. This dissapointed me because I want to do as little work as possible and it meant I would have to add it myself :(
So instead of remaking all your contracts and testing them like a responsible adult I figured I would just haphazardly throw some extra functionality in
just enough so it compiles and barely works and let you guys do the rest. So without further ado here is my explanation of whats going on in these changes

first of all most of the changes are changing syntax or adding explicit conversions to make newer compiler versions happy so you can ignore 90% of my changes

Secondly I suppose I should somewhat explain what the cloneFactory does, here are some links (https://github.com/optionality/clone-factory) (https://github.com/optionality/EIPs/blob/master/EIPS/eip-1167.md)

basically it makes cheap clones of existing contracts with separate state. I'd tell you more, but I'm not smart enough to have any idea how it actually works.
Did I say cheap clones? I meant VERY cheap clones, by my calculations this will save your users approximately 10 metric fucktons of gas every time they create a new market. (in all seriousness you're looking at about a >90% gas cost reduction)

Here's an example of Augur itself using the clone factory BTW (https://github.com/AugurProject/augur/blob/master/packages/augur-core/source/contracts/factories/ShareTokenFactory.sol) 

And finally onto the changes....

The first thing you will notice is that I've added two files CloneFactory.sol and CloneFactory16.sol, these are straight out of the clone factory library.

next there are important changes in VirtualAugurShare and VirtualAugurShareFactory. I removed the constructor in VirtualAugurShare and added some initialization
functions, this is because the cloneFactory can't call the constructor when making a clone. The initialization function just does everything the constructor does. I
also added an extra modifier so those initialization functions can only be called once.

In VirtualAugurShareFactory I imported CloneFactory16, this is an extra optimization that I will discuss later. CloneFactory16 can just be considered the regular
CloneFactory for now. Inheriting from CloneFactory gives us the createClone method which takes the address of the deployed VirtualAugurShare contract and clones it
cheaply, returning the address of the cloned contract. We call createClone in the create() function and then call the initialization functions in the new clone and
we're all done!

Now for the extra optimization: CloneFactory16 shaves off the first four 0's of a contract address so that it uses even less storage on the EVM. So by creating a
vanity contract address using vanity-eth (https://github.com/MyEtherWallet/VanityEth) with the command vanity-eth -i 0000 --contract, we can make our clones even
cheaper! You will notice that the address of the contract being cloned starts with four 0's for this reason. I have edited the ganache.sh file to initialize ganache
with one such vanity address (0xb142bee56c35df2906f013edfffe901c0b2502b9) private key: 0xa66195e41058b11e278a65c0e811944857c08d78d618e1fffdcc99cf3e9cec5a
the other account is used to deploy the contracts other than VirtualAugurShare because the vanity address will can only create its first ever contract with four
leading 0's. I have also modified the migrations scripts so that each contract is deployed by the correct address.

I think that just about covers it, if you have any questions I'll be in your discord most evenings. Thanks so much by the way for helping to grow augur :) 
you guys are pioneers <3
