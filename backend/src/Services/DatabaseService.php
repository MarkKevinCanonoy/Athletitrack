<?php

namespace App\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;

class DatabaseService {
    private Client $client;
    private string $supabaseUrl;
    private string $supabaseKey;

    public function __construct() {
        // In production, these should be loaded from environment variables (.env)
        $this->supabaseUrl = getenv('SUPABASE_URL') ?: 'https://mock-url.supabase.co';
        $this->supabaseKey = getenv('SUPABASE_KEY') ?: 'mock-key';

        $this->client = new Client([
            'base_uri' => $this->supabaseUrl . '/rest/v1/',
            'headers' => [
                'apikey' => $this->supabaseKey,
                'Authorization' => 'Bearer ' . $this->supabaseKey,
                'Content-Type' => 'application/json',
                'Prefer' => 'return=representation'
            ]
        ]);
    }

    /**
     * Perform a generic GET query against a Supabase table
     */
    public function select(string $table, array $queryParams = []) {
        try {
            $response = $this->client->request('GET', $table, [
                'query' => $queryParams
            ]);
            return json_decode($response->getBody()->getContents(), true);
        } catch (GuzzleException $e) {
            error_log("Database Select Error: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Insert a row into a Supabase table
     */
    public function insert(string $table, array $data) {
        try {
            $response = $this->client->request('POST', $table, [
                'json' => $data
            ]);
            return json_decode($response->getBody()->getContents(), true);
        } catch (GuzzleException $e) {
            error_log("Database Insert Error: " . $e->getMessage());
            return null;
        }
    }

    /**
     * Update a row in a Supabase table
     */
    public function update(string $table, array $matchCriteria, array $data) {
        try {
            $query = [];
            foreach ($matchCriteria as $key => $value) {
                $query[$key] = 'eq.' . $value;
            }
            
            $response = $this->client->request('PATCH', $table, [
                'query' => $query,
                'json' => $data
            ]);
            return json_decode($response->getBody()->getContents(), true);
        } catch (GuzzleException $e) {
            error_log("Database Update Error: " . $e->getMessage());
            return null;
        }
    }
}
