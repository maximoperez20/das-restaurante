package ar.edu.ubp.das.dto.request;

/**
 * DTO para request de obtener sucursales.
 */
public class GetSucursalesRequest {
    
    private String nroRestaurante;
    
    public GetSucursalesRequest() {}
    
    public GetSucursalesRequest(String nroRestaurante) {
        this.nroRestaurante = nroRestaurante;
    }
    
    public String getNroRestaurante() {
        return nroRestaurante;
    }
    
    public void setNroRestaurante(String nroRestaurante) {
        this.nroRestaurante = nroRestaurante;
    }

    private String nroSucursal;

    public String getNroSucursal() {
        return nroSucursal;
    }

    public void setNroSucursal(String nroSucursal) {
        this.nroSucursal = nroSucursal;
    }
}