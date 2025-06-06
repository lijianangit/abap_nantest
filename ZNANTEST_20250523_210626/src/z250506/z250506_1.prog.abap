
report z250506_1.

message i001(00) with 'No local currecny maintained for company:' 'xxxx'.
message |SABAP_DOCUSABAP_123213DOqeqweC| type 'I'.
data t   type c length 1 value 'S'.
data id  type c length 2 value '00'.
data num type c length 3 value '002'.
message id sy-msgid type sy-msgty number sy-msgno
        into data(mtext)
        with |xxx1| |xxx2| |xxx3| |xxx4|.
write mtext.

message 'Message in a Method' type 'I' raising exc1.
