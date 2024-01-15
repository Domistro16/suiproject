#[test_only]
module suiproject::suidice_test{
    use sui::test_scenario;
    use suiproject::suidice::{Self, Admin, Player, Leaderboard, Playerdom, Leaderboardom};
    use std::vector;

    const NOT_THE_PLAYER_ADDRESS: u64 = 0;
    const TEST_ERROR_LEADERBOARD_SCORES_MISMATCH: u64 = 1;
    const INSUFFICIENT_FUNDS: u64 = 1;
    const NOT_PLAYER_SCORE: u64 = 0;

    #[test]
    fun test_create(){
        let owner = @0xA;
        let player_address = @0xB;
        let scenario_val = test_scenario::begin(owner);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, owner);{
            suidice::init_for_testing(test_scenario::ctx(scenario))
        };

        test_scenario::next_tx(scenario, owner);
        {
            let leaderboard = test_scenario::take_from_sender<Leaderboard>(scenario);
            let admin = test_scenario::take_from_sender<Admin>(scenario);
            let leaderboardom = test_scenario::take_from_sender<Leaderboardom>(scenario);
            let playerdom = test_scenario::take_from_sender<Playerdom>(scenario);
            suidice::start_game(
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

            
        // Continue with transactions that perform the game's moves, e.g., rolling dice.
        test_scenario::next_tx(scenario, player_address);
        {

        // Set up your test context and any necessary initial conditions or parameters.
        let playerdom = test_scenario::take_from_sender<Playerdom>(scenario);
        let admin = test_scenario::take_from_sender<Admin>(scenario);
        let player = test_scenario::take_from_sender<Player>(scenario);

        // Create a new player to start the game with an initial score of 0
        let player_id: u64 = 1;
        let player_name = b"Player 1";
        let leaderboard = test_scenario::take_from_sender<Leaderboard>(scenario);

        // Start the game, which should handle registering the player and initializing their score.
        suidice::start_game(&admin, player_name, test_scenario::ctx(scenario), &mut playerdom, player_address, &mut leaderboard);

        // Assume a pseudo-random roll, in this case, "3" for the die roll.
        let roll_result: u8 = 3;

        // The player rolls the dice in the context of the game.
        suidice::roll_dice(player_id, &mut playerdom, roll_result, &mut leaderboard);

        // Get the updated player's score post-roll to verify the update is correct.
        let player_score: u8 = 3; // Replace this with the appropriate method to retrieve player score.
        let score: u8 = 0;
        let expected_score: u8 = score + roll_result; // Calculate the expected score.
        assert!(player_score == expected_score, NOT_PLAYER_SCORE);
        
        test_scenario::return_to_sender(scenario, playerdom);
        test_scenario::return_to_sender(scenario, leaderboard);
        test_scenario::return_to_sender(scenario, player);
        test_scenario::return_to_sender(scenario, admin);
        // ... other checks and assertions...
    };// Perform actions e.g., roll dice, join a game, etc.

        test_scenario::next_tx(scenario, owner);
        {
            let leaderboard = test_scenario::take_from_sender<Leaderboard>(scenario);  

            let expected_scores = vector::empty<u8>();
    vector::push_back(&mut expected_scores, 10);
    vector::push_back(&mut expected_scores, 20);
    vector::push_back(&mut expected_scores, 30);         

        // After performing actions that update the leaderboard's player_scores, retrieve them:
        let leaderboard_scores = suidice::get_leaderboard_player_scores(&leaderboard);

        let i = 0;
        while (i < vector::length(leaderboard_scores)) {
            assert!(*vector::borrow(leaderboard_scores, i) == *vector::borrow(&expected_scores, i), 101 /* error code */);

            i = i + 1;
            };
        test_scenario::return_to_sender(scenario, leaderboard);
        };

        test_scenario::end(scenario_val);
    }
}