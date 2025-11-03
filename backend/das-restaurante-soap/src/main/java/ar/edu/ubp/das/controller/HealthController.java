package ar.edu.ubp.das.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/health")
public class HealthController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "das-restaurante-soap");
        return response;
    }

    @GetMapping("/db")
    public Map<String, Object> checkDatabase() {
        Map<String, Object> response = new HashMap<>();
        try {
            Integer result = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            response.put("database", "CONNECTED");
            response.put("test_query", result);
            
            String dbName = jdbcTemplate.queryForObject(
                "SELECT DB_NAME()", 
                String.class
            );
            response.put("database_name", dbName);
            
            Integer tableCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'", 
                Integer.class
            );
            response.put("tables_count", tableCount);
            
        } catch (Exception e) {
            response.put("database", "ERROR");
            response.put("error", e.getMessage());
        }
        return response;
    }
}
