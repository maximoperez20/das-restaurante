package ar.edu.ubp.das.components;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.util.List;
import java.util.Map;

@Component
public class SimpleJdbcCallFactory {

    @Autowired
    private DataSource dataSource;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public <T> List<T> executeQuery(String procedureName, String schemaName, String resultSetName, Class<T> clazz) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(dataSource)
            .withSchemaName(schemaName)
            .withProcedureName(procedureName)
            .withoutProcedureColumnMetaDataAccess()
            .returningResultSet(resultSetName, BeanPropertyRowMapper.newInstance(clazz));
        
        Map<String, Object> result = jdbcCall.execute();
        
        for (Map.Entry<String, Object> entry : result.entrySet()) {
            if (entry.getValue() instanceof List) {
                @SuppressWarnings("unchecked")
                List<T> resultList = (List<T>) entry.getValue();
                return resultList;
            }
        }
        return List.of();
    }

    public <T> List<T> executeQuery(String procedureName, String schemaName, SqlParameterSource params, 
                                      String resultSetName, Class<T> clazz) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(dataSource)
            .withSchemaName(schemaName)
            .withProcedureName(procedureName)
            .returningResultSet(resultSetName, BeanPropertyRowMapper.newInstance(clazz));
        
        Map<String, Object> result = jdbcCall.execute(params);
        
        for (Map.Entry<String, Object> entry : result.entrySet()) {
            if (entry.getValue() instanceof List) {
                @SuppressWarnings("unchecked")
                List<T> resultList = (List<T>) entry.getValue();
                return resultList;
            }
        }
        return List.of();
    }

    public Map<String, Object> executeWithOutputs(String procedureName, String schemaName, SqlParameterSource params) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(dataSource)
            .withSchemaName(schemaName)
            .withProcedureName(procedureName);
        
        return jdbcCall.execute(params);
    }

    public Map<String, Object> execute(String procedureName, String schemaName) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(dataSource)
            .withSchemaName(schemaName)
            .withProcedureName(procedureName);
        
        return jdbcCall.execute();
    }

    public JdbcTemplate getJdbcTemplate() {
        return jdbcTemplate;
    }
}

