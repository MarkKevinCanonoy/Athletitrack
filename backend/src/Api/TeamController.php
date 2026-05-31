<?php

namespace App\Api;

use App\Services\DatabaseService;

class TeamController {
    private DatabaseService $db;

    public function __construct() {
        $this->db = new DatabaseService();
    }

    public function createTeam(array $data) {
        // Validate payload
        if (empty($data['coach_id']) || empty($data['name']) || empty($data['team_code'])) {
            http_response_code(400);
            echo json_encode(['status' => 'error', 'message' => 'Missing required fields (coach_id, name, team_code).']);
            return;
        }

        // Check if team code already exists
        $existing = $this->db->select('teams', ['team_code=eq.' . $data['team_code']]);
        if (!empty($existing)) {
            http_response_code(409);
            echo json_encode(['status' => 'error', 'message' => 'Team code already exists. Try generating another one.']);
            return;
        }

        // Insert new team
        $team = $this->db->insert('teams', [
            'coach_id' => $data['coach_id'],
            'name' => $data['name'],
            'description' => $data['description'] ?? null,
            'team_code' => $data['team_code'],
            'category' => $data['category'] ?? null,
            'skill_level' => $data['skill_level'] ?? null
        ]);

        if ($team !== null) {
            echo json_encode(['status' => 'success', 'message' => 'Team created successfully.', 'team' => $team]);
        } else {
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Failed to create team.']);
        }
    }

    public function listCoachTeams(array $data) {
        if (empty($data['coach_id'])) {
            http_response_code(400);
            echo json_encode(['status' => 'error', 'message' => 'Missing coach_id.']);
            return;
        }

        $teams = $this->db->select('teams', ['coach_id=eq.' . $data['coach_id']]);

        if ($teams !== null) {
            echo json_encode(['status' => 'success', 'teams' => $teams]);
        } else {
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Failed to fetch teams.']);
        }
    }
}
