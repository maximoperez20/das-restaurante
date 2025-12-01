package ar.edu.ubp.das.endpoint.util;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.Map;

/**
 * Utilidad para parsear JSON de manera segura y consistente.
 * Encapsula la lógica de parsing y manejo de errores.
 * 
 * Principio de responsabilidad única: Solo se encarga de parsear JSON.
 */
public class JsonParser {
    
    private final Gson gson;
    private static final Type MAP_TYPE = new TypeToken<Map<String, Object>>(){}.getType();
    
    public JsonParser(Gson gson) {
        this.gson = gson;
    }
    
    /**
     * Parsea un JSON string a un Map.
     * 
     * @param jsonString JSON string a parsear
     * @return Map con los datos parseados
     * @throws JsonSyntaxException Si el JSON es inválido
     */
    public Map<String, Object> parseToMap(String jsonString) throws JsonSyntaxException {
        return gson.fromJson(jsonString, MAP_TYPE);
    }
    
    /**
     * Parsea un JSON string a un objeto tipado.
     * 
     * @param jsonString JSON string a parsear
     * @param clazz Clase del objeto destino
     * @param <T> Tipo del objeto
     * @return Objeto parseado
     * @throws JsonSyntaxException Si el JSON es inválido
     */
    public <T> T parseToObject(String jsonString, Class<T> clazz) throws JsonSyntaxException {
        return gson.fromJson(jsonString, clazz);
    }
    
    /**
     * Extrae un valor del Map de manera segura.
     * 
     * @param map Map del cual extraer
     * @param key Clave a buscar
     * @param clazz Clase esperada
     * @param <T> Tipo del valor
     * @return Valor extraído o null si no existe
     */
    @SuppressWarnings("unchecked")
    public <T> T getValue(Map<String, Object> map, String key, Class<T> clazz) {
        Object value = map.get(key);
        if (value == null) {
            return null;
        }
        if (clazz.isInstance(value)) {
            return (T) value;
        }
        return null;
    }
    
    /**
     * Extrae un String del Map de manera segura.
     */
    public String getString(Map<String, Object> map, String key) {
        return getValue(map, key, String.class);
    }
    
    /**
     * Extrae un Integer del Map de manera segura.
     */
    public Integer getInteger(Map<String, Object> map, String key) {
        Object value = map.get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }
        return null;
    }
}
