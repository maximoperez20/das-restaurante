package ar.edu.ubp.das.dto;

public class ZonaDto {
    private String nroRestaurante;
    private String nroSucursal;
    private String codZona;
    private String nomZona;
    private Integer cantComensales;
    private Boolean permiteMenores;
    private Boolean habilitada;

    public String getNroRestaurante() {
        return nroRestaurante;
    }

    public void setNroRestaurante(String nroRestaurante) {
        this.nroRestaurante = nroRestaurante;
    }

    public String getNroSucursal() {
        return nroSucursal;
    }

    public void setNroSucursal(String nroSucursal) {
        this.nroSucursal = nroSucursal;
    }

    public String getCodZona() {
        return codZona;
    }

    public void setCodZona(String codZona) {
        this.codZona = codZona;
    }

    public String getNomZona() {
        return nomZona;
    }

    public void setNomZona(String nomZona) {
        this.nomZona = nomZona;
    }

    public Integer getCantComensales() {
        return cantComensales;
    }

    public void setCantComensales(Integer cantComensales) {
        this.cantComensales = cantComensales;
    }

    public Boolean getPermiteMenores() {
        return permiteMenores;
    }

    public void setPermiteMenores(Boolean permiteMenores) {
        this.permiteMenores = permiteMenores;
    }

    public Boolean getHabilitada() {
        return habilitada;
    }

    public void setHabilitada(Boolean habilitada) {
        this.habilitada = habilitada;
    }
}
