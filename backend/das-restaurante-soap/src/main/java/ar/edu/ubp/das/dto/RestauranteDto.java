package ar.edu.ubp.das.dto;

public class RestauranteDto {
    private String nroRestaurante;
    private String razonSocial;
    private String cuit;

    public String getNroRestaurante() {
        return nroRestaurante;
    }

    public void setNroRestaurante(String nroRestaurante) {
        this.nroRestaurante = nroRestaurante;
    }

    public String getRazonSocial() {
        return razonSocial;
    }

    public void setRazonSocial(String razonSocial) {
        this.razonSocial = razonSocial;
    }

    public String getCuit() {
        return cuit;
    }

    public void setCuit(String cuit) {
        this.cuit = cuit;
    }
}

