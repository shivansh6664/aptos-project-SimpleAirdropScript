module MyModule::SimpleAirdrop {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

    /// Struct representing an airdrop campaign.
    struct AirdropCampaign has store, key {
        total_distributed: u64,  // Total tokens distributed
        is_active: bool,         // Whether the airdrop is active
        admin: address,          // Admin who can execute airdrops
    }

    /// Function to initialize an airdrop campaign.
    public fun initialize_airdrop(admin: &signer) {
        let admin_address = signer::address_of(admin);
        let campaign = AirdropCampaign {
            total_distributed: 0,
            is_active: true,
            admin: admin_address,
        };
        move_to(admin, campaign);
    }

    /// Function to distribute tokens to multiple recipients.
    public fun distribute_tokens(
        admin: &signer, 
        recipients: vector<address>, 
        amounts: vector<u64>
    ) acquires AirdropCampaign {
        let admin_address = signer::address_of(admin);
        let campaign = borrow_global_mut<AirdropCampaign>(admin_address);
        
        // Ensure only admin can distribute
        assert!(campaign.admin == admin_address, 1);
        assert!(campaign.is_active, 2);
        
        // Ensure recipients and amounts vectors have same length
        assert!(vector::length(&recipients) == vector::length(&amounts), 3);
        
        let i = 0;
        let len = vector::length(&recipients);
        
        while (i < len) {
            let recipient = *vector::borrow(&recipients, i);
            let amount = *vector::borrow(&amounts, i);
            
            // Transfer tokens from admin to recipient
            let tokens = coin::withdraw<AptosCoin>(admin, amount);
            coin::deposit<AptosCoin>(recipient, tokens);
            
            // Update total distributed
            campaign.total_distributed = campaign.total_distributed + amount;
            
            i = i + 1;
        };
    }
}