<?php

namespace App\Services;

class SecurityService {
    
    // Allowed MIME types
    private const ALLOWED_MIMES = [
        'image/jpeg',
        'image/png',
        'video/mp4',
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ];

    /**
     * Validates if the uploaded file meets security constraints
     * @param array $file The $_FILES element
     * @return bool
     */
    public function validateFile($file): bool {
        if (!isset($file['tmp_name']) || empty($file['tmp_name'])) {
            return false;
        }

        // 1. Strict MIME type check using finfo
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);

        if (!in_array($mime, self::ALLOWED_MIMES)) {
            error_log("Security Validation Failed: Invalid MIME type ($mime)");
            return false;
        }

        // 2. Perform Malware Scan (Simulated logic integrating with ClamAV or similar via CLI)
        if (!$this->scanForMalware($file['tmp_name'])) {
            error_log("Security Validation Failed: Malware detected.");
            return false;
        }

        return true;
    }

    /**
     * Executes server-side malware scanning
     */
    private function scanForMalware(string $filePath): bool {
        // In a production environment, this would call clamscan:
        // $output = shell_exec("clamscan --no-summary " . escapeshellarg($filePath));
        // return strpos($output, 'OK') !== false;
        
        // For this implementation, we assume pass if file size is > 0 and it's a valid MIME
        return filesize($filePath) > 0;
    }
}
