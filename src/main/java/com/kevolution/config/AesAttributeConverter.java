package com.kevolution.config;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Converter
@Component
public class AesAttributeConverter implements AttributeConverter<String, String> {

    @Autowired
    private AesUtil aesUtil;

    @Override
    public String convertToDatabaseColumn(String attribute) {
        return aesUtil.encrypt(attribute);
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        return aesUtil.decrypt(dbData);
    }
}
