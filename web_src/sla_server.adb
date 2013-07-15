--
-- $Revision $
-- $Author $
-- $Date $
--
with Ada.Text_IO;

with AWS.Server;
with AWS.Services.Dispatchers.URI;
with AWS.Services.Page_Server;
with AWS.Config; use AWS.Config;
with AWS.Config.Set; use AWS.Config.Set;
with legal_aid_callback;
with legal_aid_output_callback;
with AWS.Log;
with la_log;
with AWS.Services; use AWS.Services;
with web_constants;

procedure sla_server is
        MY_PORT       : constant := 9091;
        my_server     : AWS.Server.HTTP;
        my_dispatcher : AWS.Services.Dispatchers.URI.Handler;
        my_config     : AWS.Config.Object := AWS.Config.Get_Current;

begin
        aws.log.start ( log=>la_log.logger, split=>aws.log.none, filename_prefix=>"sla_logger" );

        Ada.Text_IO.Put_Line
               ("Call me on port" &
                Positive'Image ( MY_PORT ) &
                "press q to stop me ...");
        AWS.Config.Set.Server_Name( my_config, "Scottish Legal Aid Simulation Server" );
        AWS.Config.Set.Server_Port( my_config, MY_PORT );
        AWS.Config.Set.WWW_Root ( my_config, web_constants.SERVER_ROOT );
        AWS.Config.Set.Max_Connection ( my_config, 10 );
        AWS.Config.Set.Session ( my_config, true );
        AWS.Config.Set.Session_Lifetime ( Duration(72_000) ); -- 2 hours

        Dispatchers.URI.Register_Regexp ( my_dispatcher, "/.*\.css|/.*\.js|/.*\.png|/.*\.html",
                                         AWS.Services.Page_Server.callback'Access );
        Dispatchers.URI.Register ( my_dispatcher, "/slab/actions/",  legal_aid_callback.input_callback'Access );
        Dispatchers.URI.Register ( my_dispatcher, "/slab/output/",  legal_aid_output_callback.output_callback'Access );
        Dispatchers.URI.Register ( my_dispatcher, "/slab/intro_page.thtml",  legal_aid_callback.intro_callback'Access );
        Dispatchers.URI.Register ( my_dispatcher, "/slab/intro/",  legal_aid_callback.intro_callback'Access );
        Dispatchers.URI.Register ( my_dispatcher, "/slab/",  legal_aid_callback.intro_callback'Access );
        AWS.Server.Start( my_server,
           Dispatcher => my_dispatcher,
           Config => my_config );
--                Max_Connection => 10,
--                Port           => MY_PORT,
--                Session        => true

        AWS.Server.Wait( AWS.Server.forever ); -- (AWS.Server.Q_Key_Pressed);

        AWS.Server.Shutdown (my_server);
end sla_server;
