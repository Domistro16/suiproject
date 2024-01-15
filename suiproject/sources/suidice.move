module suiproject::suidice {
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};
    use sui::event;
    use std::vector;

    const NOT_THE_OWNER: u64 = 0;
    const INSUFFICIENT_FUNDS: u64 = 1;
    const MIN_CARD_COST: u64 = 1;

    struct Admin has key{
        id: UID,
    }

    struct Player has key, store{
        id: UID,
        address: address,
        owner: address,
        latest_roll: Option<u8>, // Last roll value, None if not rolled yet.
        score: u8, // Total score for the leaderboard.
        name: String, // Player's name for the leaderboard.
    }
    struct Leaderboard has key, store {
        id: UID,
        owner: address,
        player_addresses: vector<address>,   // Vector storing `UID`s of players
        player_scores: vector<u8>, // Contains player scores and other info
}
    struct Playerdom has key{
        id: UID,
        owner: address,
        players: ObjectTable<u64, Player>,
        counter: u64,
    }
     struct Leaderboardom has key{
        id: UID,
        owner: address,
        counter: u64,
        leaderboards: ObjectTable<u64, Leaderboard>,
     }   
    
     struct PlayerCreated has copy, drop{
        id: ID,
        address: address,
        name: String,
        owner: address,
    }

    struct LeaderboardCreated has copy, drop{
        id: ID,
        owner: address,
    }

    fun init(ctx: &mut TxContext) {
        
        let playerdomm = Playerdom { 
        id: object::new(ctx),
        counter: 0,
        owner: tx_context::sender(ctx),
        players: object_table::new(ctx),
        };
        transfer::share_object(playerdomm);

        let leaderboardomm = Leaderboardom{
            id: object::new(ctx),
            counter:0,
            owner: tx_context::sender(ctx),
            leaderboards: object_table::new(ctx),
        };
        transfer::share_object(leaderboardomm);
    }

    public fun start_game(
    _: &Admin,
    name: vector<u8>,
    ctx: &mut TxContext, 
    playerdom: &mut Playerdom, 
    address: address, 
    leaderboard: &mut Leaderboard
    ) {
        let id = object::new(ctx);
        event::emit(
            PlayerCreated{
                    id: object::uid_to_inner(&id),
                    address: tx_context::sender(ctx),
                    name: string::utf8(name),
                    owner: tx_context::sender(ctx),
                }

        );
        let player = Player {
        name: string::utf8(name), 
        id: id,
        address,
        owner: tx_context::sender(ctx),
        latest_roll: option::none(),
        score: 0, 
        };

        
        vector::push_back(&mut leaderboard.player_addresses, player.address);
        vector::push_back(&mut leaderboard.player_scores, 0);
        object_table::add(&mut playerdom.players, playerdom.counter, player);

        playerdom.counter = playerdom.counter + 1;
    }

    public fun roll_dice( id: u64, playerdom: &mut Playerdom, pseudo_random_number: u8, leaderboard: &mut Leaderboard) {
     let roll = (pseudo_random_number % 6) + 1; // Adjust for a range of 1 to 6
 
    let player = object_table::borrow_mut(&mut playerdom.players, id);
    player.latest_roll = option::some(roll);
     player.score = player.score + roll; // Ensure this matches the type of `score` in Player

    update_leaderboard(player, leaderboard);

}

    public fun create_leaderboard(
        _: &Admin, 
        ctx: &mut TxContext, 
        leaderboardom: &mut Leaderboardom) {

                   let id = object::new(ctx);

            event::emit(
            LeaderboardCreated{
                    id: object::uid_to_inner(&id),
                    owner: tx_context::sender(ctx),
                }
        );

        let leaderboard = Leaderboard {
            id: id,
            owner: tx_context::sender(ctx),
            player_scores: vector::empty(),
            player_addresses: vector::empty()
        };
        // Using a constant key for the leaderboard.
        object_table::add(&mut leaderboardom.leaderboards, leaderboardom.counter, leaderboard)
    }

    // Update leaderboard entries and sort by high score.
public fun update_leaderboard(player: &Player, leaderboard: &mut Leaderboard) {
    let player_id = player.address; // Reference the player's address
    let player_score = player.score; // Get the score from the reference
    let found = false;
    let i: u64 = 0;

    // Search for the reference to the address in the leaderboard's player_ids vector
    while (i < vector::length(&leaderboard.player_addresses)) {
        if (*vector::borrow(&leaderboard.player_addresses, i) == player_id) {
            found = true;
            break
        };
        i = i + 1;
    };

    // If the reference was found in the player_ids, update the corresponding score
    if (found) {
        let total_score = vector::borrow_mut(&mut leaderboard.player_scores, i);
        *total_score = *total_score + player_score;
    } else {
        vector::push_back(&mut leaderboard.player_addresses, player_id);
        vector::push_back(&mut leaderboard.player_scores, player_score);
    };
}


    // function to get the current leaderboard.
    public fun get_leaderboard_player_scores(leaderboard: &Leaderboard): &vector<u8> {
    &leaderboard.player_scores
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext){
    init(ctx);
}
#[test_only]
    use sui::test_scenario;

    #[test]
    fun test_create(){
        let owner = @0xA;
        let player_address = @0xB;
        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, owner);{
            init_for_testing(test_scenario::ctx(scenario))
        };

        test_scenario::next_tx(scenario, owner);
        {
            let leaderboard = test_scenario::take_from_sender<Leaderboard>(scenario);
            let admin = test_scenario::take_from_sender<Admin>(scenario);
            let leaderboardom = test_scenario::take_from_sender<Leaderboardom>(scenario);
            let playerdom = test_scenario::take_from_sender<Playerdom>(scenario);
            start_game(
                &admin,
                b"Player 1",
                test_scenario::ctx(scenario),
                &mut playerdom,
                player_address,
                &mut leaderboard 
            );

          assert!(test_scenario::has_most_recent_for_sender<Player>(scenario), 0);

            
            test_scenario::return_to_sender(scenario, leaderboard);
            test_scenario::return_to_sender(scenario, admin);
            test_scenario::return_to_sender(scenario, leaderboardom);
            test_scenario::return_to_sender(scenario, playerdom);
        };

        test_scenario::next_tx(scenario, owner);
        {
            let leaderboardom = test_scenario::take_from_sender<Leaderboardom>(scenario);
            let admin = test_scenario::take_from_sender<Admin>(scenario);

            create_leaderboard(&admin, test_scenario::ctx(scenario), &mut leaderboardom);

            
            test_scenario::return_to_sender<Admin>(scenario, admin);
            test_scenario::return_to_sender<Leaderboardom>(scenario, leaderboardom);

        };      
        // Continue with transactions that perform the game's moves, e.g., rolling dice.
        test_scenario::next_tx(scenario, player_address);
        {

        // Set up your test context and any necessary initial conditions or parameters.
        let playerdom = test_scenario::take_from_sender<Playerdom>(scenario);
        let admin = test_scenario::take_from_sender<Admin>(scenario);
        let player = test_scenario::take_from_sender<Player>(scenario);

        // Create a new player to start the game with an initial score of 0
        let player_id: u64 = 1;
        let leaderboard = test_scenario::take_from_sender<Leaderboard>(scenario);

        let roll_result: u8 = 3;

        // The player rolls the dice in the context of the game.
        roll_dice(player_id, &mut playerdom, roll_result, &mut leaderboard);

        // Get the updated player's score post-roll to verify the update is correct.
        
        update_leaderboard(&player,&mut leaderboard);
        
        test_scenario::return_to_sender(scenario, playerdom);
        test_scenario::return_to_sender(scenario, leaderboard);
        test_scenario::return_to_sender(scenario, player);
        test_scenario::return_to_sender(scenario, admin);
    };// Perform actions e.g., roll dice, join a game, etc.

        test_scenario::next_tx(scenario, player_address);
        {
            let leaderboard = test_scenario::take_from_sender<Leaderboard>(scenario);  

            get_leaderboard_player_scores(&leaderboard);

            assert!(test_scenario::has_most_recent_for_sender<Leaderboard>(scenario), 0);
        test_scenario::return_to_sender(scenario, leaderboard);
        };

        test_scenario::end(scenario_val);
    }
}
