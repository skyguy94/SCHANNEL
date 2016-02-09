Configuration IISCrypto16Build7
{
    Import-DscResource -Module SCHANNEL

    SSLProtocol
    {
        Protocol = 'Multi-Protocol Unified Hello'
        Ensure = Absent
    }

    SSLProtocol
    {
        Protocol = 'PCT 1.0'
        Ensure = Absent
    }
    SSLProtocol
    {
        Protocol = 'SSL 2.0'
        Ensure = Absent
    }
    SSLProtocol
    {
        Protocol = 'SSL 3.0'
        Ensure = Absent
    }
    SSLProtocol
    {
        Protocol = 'TLS 1.0'
        Ensure = Present
    }
    SSLProtocol
    {
        Protocol = 'TLS 1.1'
        Ensure = Present
    }
    SSLProtocol
    {
        Protocol = 'TLS 1.2'
        Ensure = Present
    }

    Hash
    {
        Hash = 'MD5'
        Ensure = Present
    }
    Hash
    {
        Hash = 'SHA'
        Ensure = Present
    }
    Hash
    {
        Hash = 'SHA256'
        Ensure = Present
    }
    Hash
    {
        Hash = 'SHA384'
        Ensure = Present
    }
    Hash
    {
        Hash = 'SHA512'
        Ensure = Present
    }

    KeyExchangeAlgorithm
    {
        Algorithm = 'Diffie-Hellman'
        Ensure = Present
    }
    KeyExchangeAlgorithm
    {
        Algorithm = 'EDCH'
        Ensure = Present
    }
    KeyExchangeAlgorithm
    {
        Algorithm = 'PKCS'
        Ensure = Present
    }

    Cipher NULL
    {
        Cipher = 'NULL'
        Ensure = Absent
    }
    Cipher 'DES 56/56'
    {
        Cipher = 'DES 56/56'
        Ensure = Absent
    }
    Cipher
    {
        Cipher = 'RC2 128/128'
        Ensure = Absent
    }
    Cipher
    {
        Cipher = 'RC2 40/128'
        Ensure = Absent
    }
    Cipher
    {
        Cipher = 'RC2 56/128'
        Ensure = Absent
    }
    Cipher
    {
        Cipher = 'RC4 128/128'
        Ensure = Absent
    }
    Cipher
    {
        Cipher = 'RC4 40/128'
        Ensure = Absent
    }
    Cipher
    {
        Cipher = 'RC4 56/128'
        Ensure = Absent
    }
    Cipher
    {
        Cipher = 'RC4 64/128'
        Ensure = Absent
    }
    Cipher
    {
        Cipher = 'AES 128/128'
        Ensure = Present
    }
    Cipher
    {
        Cipher = 'AES 256/256'
        Ensure = Present
    }
    Cipher
    {
        Cipher = 'Triple DES 168/168'
        Ensure = Present
    }


    CipherOrder
    {
        Ciphers = 'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P521',
                                   'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P384',
                                   'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P256',
                                   'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P521',
                                   'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P384',
                                   'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P256',
                                   'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P521',
                                   'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P384',
                                   'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256',
                                   'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P521',
                                   'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P384',
                                   'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256',
                                   'TLS_RSA_WITH_AES_256_CBC_SHA256',
                                   'TLS_RSA_WITH_AES_256_CBC_SHA',
                                   'TLS_RSA_WITH_AES_128_CBC_SHA256',
                                   'TLS_RSA_WITH_AES_128_CBC_SHA',
                                   'TLS_RSA_WITH_3DES_EDE_CBC_SHA'
       Ensure = Present
    }
}