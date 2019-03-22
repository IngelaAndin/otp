%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2019-2019. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%

%%

-module(ssl_cipher_suite_SUITE).

%% Note: This directive should only be used in test suites.
-compile(export_all).

-include_lib("common_test/include/ct.hrl").

%%--------------------------------------------------------------------
%% Common Test interface functions -----------------------------------
%%--------------------------------------------------------------------
all() -> 
    [
     {group, 'tlsv1.2'},
     {group, 'tlsv1.1'},
     {group, 'tlsv1'},
     {group, 'sslv3'},
     {group, 'dtlsv1.2'},
     {group, 'dtlsv1'}
    ].

groups() ->
    [
     {'tlsv1.2', [], kex()},
     {'tlsv1.1', [], kex()},
     {'tlsv1', [], kex()},
     {'sslv3', [], kex()},
     {'dtlsv1.2', [], kex()},
     {'dtlsv1', [], kex()},
     {dhe_rsa, [],[dhe_rsa_3des_ede_cbc, 
                   dhe_rsa_aes_128_cbc,
                   dhe_rsa_aes_256_cbc
                  ]},
     {ecdhe_rsa, [], [ecdhe_rsa_3des_ede_cbc, 
                      ecdhe_rsa_aes_128_cbc,
                      ecdhe_rsa_aes_128_gcm,
                      ecdhe_rsa_aes_256_cbc,
                      ecdhe_rsa_aes_256_gcm
                    ]},
     {ecdhe_ecdsa, [],[ecdhe_ecdsa_rc4_128, 
                       ecdhe_ecdsa_3des_ede_cbc, 
                       ecdhe_ecdsa_aes_128_cbc,
                       ecdhe_ecdsa_aes_128_gcm,
                       ecdhe_ecdsa_aes_256_cbc,
                       ecdhe_ecdsa_aes_256_gcm
                      ]},
     {rsa, [], [rsa_3des_ede_cbc, 
                rsa_aes_128_cbc,
                rsa_aes_256_cbc,
                rsa_rc4_128]},
     {dhe_dss, [], [dhe_dss_3des_ede_cbc, 
                    dhe_dss_aes_128_cbc,
                    dhe_dss_aes_256_cbc]},
     {srp_rsa, [], [srp_rsa_3des_ede_cbc, 
                    srp_rsa_aes_128_cbc,
                    srp_rsa_aes_256_cbc]},
     {srp_dss, [], [srp_dss_3des_ede_cbc, 
                    srp_dss_aes_128_cbc,
                    srp_dss_aes_256_cbc]},
     {rsa_psk, [], [rsa_psk_3des_ede_cbc,                    
                    rsa_psk_rc4_128,
                    rsa_psk_aes_128_cbc,
                    rsa_psk_aes_128_ccm,
                    rsa_psk_aes_128_ccm_8,
                    rsa_psk_aes_256_cbc,
                    rsa_psk_aes_256_ccm,
                    rsa_psk_aes_256_ccm_8
                   ]},
     {dh_anon, [], [dh_anon_rc4_128,
                    dh_anon_3des_ede_cbc, 
                    dh_anon_aes_128_cbc,
                    dh_anon_aes_128_gcm,
                    dh_anon_aes_256_cbc,
                    dh_anon_aes_256_gcm]},
     {ecdh_anon, [], [ecdh_anon_3des_ede_cbc, 
                      ecdh_anon_aes_128_cbc,
                      ecdh_anon_aes_256_cbc
                     ]},     
     {srp, [], [srp_3des_ede_cbc, 
                srp_aes_128_cbc,
                srp_aes_256_cbc]},
     {psk, [], [psk_3des_ede_cbc,                    
                psk_rc4_128,
                psk_aes_128_cbc,
                psk_aes_128_ccm,
                psk_aes_128_ccm_8,
                psk_aes_256_cbc,
                psk_aes_256_ccm,
                psk_aes_256_ccm_8
               ]},
     {dhe_psk, [], [dhe_psk_3des_ede_cbc,                    
                    dhe_psk_rc4_128,
                    dhe_psk_aes_128_cbc,
                    dhe_psk_aes_128_ccm,
                    dhe_psk_aes_128_ccm_8,
                    dhe_psk_aes_256_cbc,
                    dhe_psk_aes_256_ccm,
                    dhe_psk_aes_256_ccm_8
               ]}
    ].


kex() ->
     rsa() ++ ecdsa() ++ dss() ++ anonymous().

rsa() ->
    [{group, dhe_rsa},
     {group, ecdhe_rsa},
     {group, rsa},
     {group, srp_rsa},
     {group, rsa_psk}
    ].

ecdsa() ->
    [{group, ecdhe_ecdsa}].
    
dss() ->
    [{group, dhe_dss},
     {group, srp_dss}].

anonymous() ->
    [{group, dh_anon},
     {group, ecdh_anon},
     {group, psk},
     {group, dhe_psk},
     {group, srp}
    ].
    

init_per_suite(Config) ->
    catch crypto:stop(),
    try crypto:start() of
	ok ->
	    ssl_test_lib:clean_start(),
            Config
    catch _:_ ->
	    {skip, "Crypto did not start"}
    end.

end_per_suite(_Config) ->
    ssl:stop(),
    application:stop(crypto).

%%--------------------------------------------------------------------
init_per_group(GroupName, Config0) ->
    case ssl_test_lib:sufficient_crypto_support(GroupName) of
        true ->
              case ssl_test_lib:is_tls_version(GroupName) of
                  true ->
                      ssl_test_lib:init_tls_version(GroupName, end_per_group(GroupName, Config0));
                  false ->
                      init_certs(GroupName, Config0)
              end;
        false ->
            {skip, "Missing crypto support"}
    end.
  
end_per_group(GroupName, Config) ->
  case ssl_test_lib:is_tls_version(GroupName) of
      true ->
          ssl_test_lib:clean_tls_version(Config);
      false ->
          Config
  end.
init_per_testcase(TestCase, Config) when TestCase == srp_rsa_3des_ede_cbc;
                                         TestCase == rsa_psk_3des_ede_cbc;
                                         TestCase == rsa_3des_ede_cbc;
                                         TestCase == dhe_rsa_3des_ede_cbc;
                                         TestCase == ecdhe_rsa_3des_ede_cbc;
                                         TestCase == ecdhe_ecdsa_3des_ede_cbc ->
    SupCiphers = proplists:get_value(ciphers, crypto:supports()),
    case lists:member(des_ede3, SupCiphers) of
        true ->
            ct:timetrap({seconds, 2}),
            Config;
        _ ->
            {skip, "Missing crypto support"}
    end;
init_per_testcase(TestCase, Config) when TestCase == rsa_psk_rc4_128;
                                         TestCase == rsa_rc4_128;
                                         TestCase == ecdhe_rsa_rc4_128 ->
    SupCiphers = proplists:get_value(ciphers, crypto:supports()),
    case lists:member(rc4, SupCiphers) of
        true ->
            ct:timetrap({seconds, 2}),
            Config;
        _ ->
            {skip, "Missing crypto support"}
    end;
init_per_testcase(TestCase, Config)  ->
    Cipher = test_cipher(TestCase, Config),
    SupCiphers = proplists:get_value(ciphers, crypto:supports()),
    case lists:member(Cipher, SupCiphers) of
        true ->
            ct:timetrap({seconds, 2}),
            Config;
        _ ->
            {skip, "Missing crypto support"}
    end.

end_per_testcase(_TestCase, Config) ->
    Config.

init_certs(srp_rsa, Config) ->
    DefConf = ssl_test_lib:default_cert_chain_conf(),
    CertChainConf = ssl_test_lib:gen_conf(rsa, rsa, DefConf, DefConf),
    #{server_config := ServerOpts,
      client_config := ClientOpts} 
        = public_key:pkix_test_data(CertChainConf),
    [{tls_config, #{server_config => [{user_lookup_fun, {fun user_lookup/3, undefined}} | ServerOpts],
                    client_config => [{srp_identity, {"Test-User", "secret"}} | ClientOpts]}} |
     proplists:delete(tls_config, Config)];
init_certs(rsa_psk, Config) ->
    ClientExt = x509_test:extensions([{key_usage, [digitalSignature, keyEncipherment]}]),
    {ClientOpts, ServerOpts} = ssl_test_lib:make_rsa_cert_chains([{server_chain, 
                                                                   [[],[],[{extensions, ClientExt}]]}], 
                                                                 Config, "_peer_keyEncipherment"),
    PskSharedSecret = <<1,2,3,4,5,6,7,8,9,10,11,12,13,14,15>>,
    [{tls_config, #{server_config => [{user_lookup_fun, {fun user_lookup/3, PskSharedSecret}} | ServerOpts],
                    client_config => [{psk_identity, "Test-User"},
                                      {user_lookup_fun, {fun user_lookup/3, PskSharedSecret}} | ClientOpts]}} |
     proplists:delete(tls_config, Config)];
init_certs(rsa, Config) ->
    ClientExt = x509_test:extensions([{key_usage, [digitalSignature, keyEncipherment]}]),
    {ClientOpts, ServerOpts} = ssl_test_lib:make_rsa_cert_chains([{server_chain, 
                                                                   [[],[],[{extensions, ClientExt}]]}], 
                                                                 Config, "_peer_keyEncipherment"),
    [{tls_config, #{server_config => ServerOpts,
                    client_config => ClientOpts}} |
     proplists:delete(tls_config, Config)];
init_certs(dhe_dss, Config) ->
    DefConf = ssl_test_lib:default_cert_chain_conf(),
    CertChainConf = ssl_test_lib:gen_conf(dsa, dsa, DefConf, DefConf),
    #{server_config := ServerOpts,
      client_config := ClientOpts} 
        = public_key:pkix_test_data(CertChainConf),
    [{tls_config, #{server_config => ServerOpts,
                    client_config => ClientOpts}} |
     proplists:delete(tls_config, Config)];
init_certs(srp_dss, Config) ->
    DefConf = ssl_test_lib:default_cert_chain_conf(),
    CertChainConf = ssl_test_lib:gen_conf(dsa, dsa, DefConf, DefConf),
    #{server_config := ServerOpts,
      client_config := ClientOpts} 
        = public_key:pkix_test_data(CertChainConf),
    [{tls_config, #{server_config => [{user_lookup_fun, {fun user_lookup/3, undefined}} | ServerOpts],
                    client_config => [{srp_identity, {"Test-User", "secret"}} | ClientOpts]}} |
       proplists:delete(tls_config, Config)];
init_certs(GroupName, Config) when GroupName == dhe_rsa;
                                   GroupName == ecdhe_rsa ->
    DefConf = ssl_test_lib:default_cert_chain_conf(),
    CertChainConf = ssl_test_lib:gen_conf(rsa, rsa, DefConf, DefConf),
    #{server_config := ServerOpts,
      client_config := ClientOpts} 
        = public_key:pkix_test_data(CertChainConf),
    [{tls_config, #{server_config => ServerOpts,
                    client_config => ClientOpts}} |
     proplists:delete(tls_config, Config)];
init_certs(GroupName, Config) when GroupName == dhe_ecdsa;
                                   GroupName == ecdhe_ecdsa ->
    DefConf = ssl_test_lib:default_cert_chain_conf(),
    CertChainConf = ssl_test_lib:gen_conf(ecdsa, ecdsa, DefConf, DefConf),
    #{server_config := ServerOpts,
      client_config := ClientOpts} 
        = public_key:pkix_test_data(CertChainConf),
    [{tls_config, #{server_config => ServerOpts,
                    client_config => ClientOpts}} |
     proplists:delete(tls_config, Config)];
init_certs(psk, Config) ->
    PskSharedSecret = <<1,2,3,4,5,6,7,8,9,10,11,12,13,14,15>>,
    [{tls_config, #{server_config => [{user_lookup_fun, {fun user_lookup/3, PskSharedSecret}}],
                    client_config => [{psk_identity, "Test-User"},
                                      {user_lookup_fun, {fun user_lookup/3, PskSharedSecret}}]}} |
     proplists:delete(tls_config, Config)]; 
init_certs(srp, Config) -> 
      [{tls_config, #{server_config => [{user_lookup_fun, {fun user_lookup/3, undefined}}],
                      client_config => [{srp_identity, {"Test-User", "secret"}}]}} |
       proplists:delete(tls_config, Config)];
init_certs(_GroupName, Config) -> 
    %% Anonymous does not need certs
    Config.
%%--------------------------------------------------------------------
%% Test Cases --------------------------------------------------------
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% SRP --------------------------------------------------------
%%--------------------------------------------------------------------
srp_rsa_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(srp_rsa, '3des_ede_cbc', Config).                 
    
srp_rsa_aes_128_cbc(Config) when is_list(Config) ->
   run_ciphers_test(srp_rsa, 'aes_128_cbc', Config).             

srp_rsa_aes_256_cbc(Config) when is_list(Config) ->
   run_ciphers_test(srp_rsa, 'aes_256_cbc', Config).             

srp_dss_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(srp_dss, '3des_ede_cbc', Config).                 
    
srp_dss_aes_128_cbc(Config) when is_list(Config) ->
   run_ciphers_test(srp_dss, 'aes_128_cbc', Config).             

srp_dss_aes_256_cbc(Config) when is_list(Config) ->
   run_ciphers_test(srp_dss, 'aes_256_cbc', Config).     

%%--------------------------------------------------------------------
%% PSK --------------------------------------------------------
%%--------------------------------------------------------------------
rsa_psk_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(rsa_psk, '3des_ede_cbc', Config).            

rsa_psk_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(rsa_psk, 'aes_128_cbc', Config).             

rsa_psk_aes_128_ccm(Config) when is_list(Config) ->
    run_ciphers_test(rsa_psk, 'aes_128_ccm', Config).             

rsa_psk_aes_128_ccm_8(Config) when is_list(Config) ->
    run_ciphers_test(rsa_psk, 'aes_128_ccm_8', Config).             

rsa_psk_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(rsa_psk, 'aes_256_cbc', Config). 

rsa_psk_aes_256_ccm(Config) when is_list(Config) ->
    run_ciphers_test(rsa_psk, 'aes_256_ccm', Config).             

rsa_psk_aes_256_ccm_8(Config) when is_list(Config) ->
    run_ciphers_test(rsa_psk, 'aes_256_ccm_8', Config).             
     
rsa_psk_rc4_128(Config) when is_list(Config) ->
    run_ciphers_test(rsa_psk, 'rc4_128', Config).    
         
%%--------------------------------------------------------------------
%% RSA --------------------------------------------------------
%%--------------------------------------------------------------------
rsa_des_cbc(Config) when is_list(Config) ->
    run_ciphers_test(rsa, 'des_cbc', Config).            

rsa_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(rsa, '3des_ede_cbc', Config).            

rsa_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(rsa, 'aes_128_cbc', Config).             

rsa_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(rsa, 'aes_256_cbc', Config).

rsa_aes_128_gcm(Config) when is_list(Config) ->
    run_ciphers_test(rsa, 'aes_128_gcm', Config).             

rsa_aes_256_gcm(Config) when is_list(Config) ->
    run_ciphers_test(rsa, 'aes_256_gcm', Config).

rsa_rc4_128(Config) when is_list(Config) ->
    run_ciphers_test(rsa, 'rc4_128', Config).    
%%--------------------------------------------------------------------
%% DHE_RSA --------------------------------------------------------
%%--------------------------------------------------------------------
dhe_rsa_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_rsa, '3des_ede_cbc', Config).         

dhe_rsa_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_rsa, 'aes_128_cbc', Config).   

dhe_rsa_aes_128_gcm(Config) when is_list(Config) ->
    run_ciphers_test(dhe_rsa, 'aes_128_gcm', Config).   

dhe_rsa_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_rsa, 'aes_256_cbc', Config).   

dhe_rsa_aes_256_gcm(Config) when is_list(Config) ->
    run_ciphers_test(dhe_rsa, 'aes_256_gcm', Config).   
%%--------------------------------------------------------------------
%% ECDHE_RSA --------------------------------------------------------
%%--------------------------------------------------------------------
ecdhe_rsa_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_rsa, '3des_ede_cbc', Config).         

ecdhe_rsa_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_rsa, 'aes_128_cbc', Config).         

ecdhe_rsa_aes_128_gcm(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_rsa, 'aes_128_gcm', Config).         

ecdhe_rsa_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_rsa, 'aes_256_cbc', Config).   

ecdhe_rsa_aes_256_gcm(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_rsa, 'aes_256_gcm', Config).   

ecdhe_rsa_rc4_128(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_rsa, 'rc4_128', Config).      
%%--------------------------------------------------------------------
%% ECDHE_ECDSA --------------------------------------------------------
%%--------------------------------------------------------------------
ecdhe_ecdsa_rc4_128(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_ecdsa, 'rc4_128', Config).         

ecdhe_ecdsa_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_ecdsa, '3des_ede_cbc', Config).         

ecdhe_ecdsa_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_ecdsa, 'aes_128_cbc', Config).         

ecdhe_ecdsa_aes_128_gcm(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_ecdsa, 'aes_128_gcm', Config).         

ecdhe_ecdsa_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_ecdsa, 'aes_256_cbc', Config).   

ecdhe_ecdsa_aes_256_gcm(Config) when is_list(Config) ->
    run_ciphers_test(ecdhe_ecdsa, 'aes_256_gcm', Config).   

%%--------------------------------------------------------------------
%% DHE_DSS --------------------------------------------------------
%%--------------------------------------------------------------------
dhe_dss_des_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_dss, 'des_cbc', Config).            

dhe_dss_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_dss, '3des_ede_cbc', Config).            

dhe_dss_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_dss, 'aes_128_cbc', Config).             

dhe_dss_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_dss, 'aes_256_cbc', Config).

dhe_dss_aes_128_gcm(Config) when is_list(Config) ->
    run_ciphers_test(dhe_dss, 'aes_128_gcm', Config).             

dhe_dss_aes_256_gcm(Config) when is_list(Config) ->
    run_ciphers_test(dhe_dss, 'aes_256_gcm', Config).

%%--------------------------------------------------------------------
%% Anonymous --------------------------------------------------------
%%--------------------------------------------------------------------
dh_anon_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dh_anon, '3des_ede_cbc', Config).         

dh_anon_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dh_anon, 'aes_128_cbc', Config).         

dh_anon_aes_128_gcm(Config) when is_list(Config) ->
    run_ciphers_test(dh_anon, 'aes_128_gcm', Config).         

dh_anon_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dh_anon, 'aes_256_cbc', Config).   

dh_anon_aes_256_gcm(Config) when is_list(Config) ->
    run_ciphers_test(dh_anon, 'aes_256_gcm', Config).   

dh_anon_rc4_128(Config) when is_list(Config) ->
    run_ciphers_test(dh_anon, 'rc4_128', Config).      

ecdh_anon_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdh_anon, '3des_ede_cbc', Config).         

ecdh_anon_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdh_anon, 'aes_128_cbc', Config).   

ecdh_anon_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(ecdh_anon, 'aes_256_cbc', Config).   

srp_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(srp, '3des_ede_cbc', Config).                 
    
srp_aes_128_cbc(Config) when is_list(Config) ->
   run_ciphers_test(srp, 'aes_128_cbc', Config).             

srp_aes_256_cbc(Config) when is_list(Config) ->
   run_ciphers_test(srp, 'aes_256_cbc', Config).     

dhe_psk_des_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'des_cbc', Config).            

dhe_psk_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, '3des_ede_cbc', Config).            

dhe_psk_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'aes_128_cbc', Config).             

dhe_psk_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'aes_256_cbc', Config).

dhe_psk_aes_128_gcm(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'aes_128_gcm', Config).             

dhe_psk_aes_256_gcm(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'aes_256_gcm', Config).

dhe_psk_aes_128_ccm(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'aes_128_ccm', Config).             

dhe_psk_aes_256_ccm(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'aes_256_ccm', Config).

dhe_psk_aes_128_ccm_8(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'aes_128_ccm_8', Config).

dhe_psk_aes_256_ccm_8(Config) when is_list(Config) ->
    run_ciphers_test(dhe_psk, 'aes_256_ccm_8', Config).

psk_des_cbc(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'des_cbc', Config).            

psk_3des_ede_cbc(Config) when is_list(Config) ->
    run_ciphers_test(psk, '3des_ede_cbc', Config).            

psk_aes_128_cbc(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'aes_128_cbc', Config).             

psk_aes_256_cbc(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'aes_256_cbc', Config).

psk_aes_128_gcm(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'aes_128_gcm', Config).             

psk_aes_256_gcm(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'aes_256_gcm', Config).

psk_aes_128_ccm(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'aes_128_ccm', Config).             

psk_aes_256_ccm(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'aes_256_ccm', Config).

psk_aes_128_ccm_8(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'aes_128_ccm_8', Config).             

psk_aes_256_ccm_8(Config) when is_list(Config) ->
    run_ciphers_test(psk, 'aes_256_ccm_8', Config).

%%--------------------------------------------------------------------
%% Internal functions  ----------------------------------------------
%%--------------------------------------------------------------------
test_cipher(TestCase, Config) ->
    [{name, Group} |_] = proplists:get_value(tc_group_properties, Config),
    list_to_atom(re:replace(atom_to_list(TestCase), atom_to_list(Group) ++ "_",  "", [{return, list}])).

run_ciphers_test(Kex, Cipher, Config) ->
    Version = ssl_test_lib:protocol_version(Config),
    TestCiphers = test_ciphers(Kex, Cipher, Version),                  
    
    case TestCiphers of
        [_|_] -> 
            lists:foreach(fun(TestCipher) -> 
                                  cipher_suite_test(TestCipher, Version, Config)
                          end, TestCiphers);
        []  ->
            {skip, {not_sup, Kex, Cipher, Version}}
    end.

cipher_suite_test(CipherSuite, Version, Config) ->
    #{server_config := SOpts,
      client_config := COpts} = proplists:get_value(tls_config, Config),
    ServerOpts = ssl_test_lib:ssl_options(SOpts, Config),
    ClientOpts = ssl_test_lib:ssl_options(COpts, Config),
    ct:log("Testing CipherSuite ~p~n", [CipherSuite]),
    ct:log("Server Opts ~p~n", [ServerOpts]),
    ct:log("Client Opts ~p~n", [ClientOpts]),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    ErlangCipherSuite = erlang_cipher_suite(CipherSuite),

    ConnectionInfo = {ok, {Version, ErlangCipherSuite}},
    
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
                                        {mfa, {ssl_test_lib, cipher_result, [ConnectionInfo]}},
                                        {options, [{versions, [Version]}, {ciphers, [CipherSuite]} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
					{mfa, {ssl_test_lib, cipher_result, [ConnectionInfo]}},
					{options,
					 [{versions, [Version]}, {ciphers, [CipherSuite]} |
					  ClientOpts]}]),

    ok = ssl_test_lib:wait_for_result(Server, ok, Client, ok),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

erlang_cipher_suite(Suite) when is_list(Suite)->
    ssl_cipher_format:suite_definition(ssl_cipher_format:openssl_suite(Suite));
erlang_cipher_suite(Suite) ->
    Suite.

user_lookup(psk, _Identity, UserState) ->
    {ok, UserState};
user_lookup(srp, Username, _UserState) ->
    Salt = ssl_cipher:random_bytes(16),
    UserPassHash = crypto:hash(sha, [Salt, crypto:hash(sha, [Username, <<$:>>, <<"secret">>])]),
    {ok, {srp_1024, Salt, UserPassHash}}.

test_ciphers(Kex, Cipher, Version) ->
    ssl:filter_cipher_suites(ssl:cipher_suites(all, Version), 
                             [{key_exchange, 
                               fun(Kex0) when Kex0 == Kex -> true; 
                                  (_) -> false 
                               end}, 
                              {cipher,  
                               fun(Cipher0) when Cipher0 == Cipher -> true; 
                                  (_) -> false 
                               end}]).
