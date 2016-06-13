var express = require('express');
var router = express.Router();
var http = require('http');
var pg = require('pg');
var multiline = require('multiline');

router.get('/t1', function (req, res) {
    var conString = res.app.get('pgConnString');
    //var handleError = res.app.get('pgErrorHandler');
    
    pg.connect(conString, function (err, client, done) {
        
        var handleError = function (err) {
            // no error occurred, continue with the request
            if (!err) return false;
            
            // An error occurred, remove the client from the connection pool.
            // A truthy value passed to done will remove the connection from the pool
            // instead of simply returning it to be reused.
            // In this case, if we have successfully received a client (truthy)
            // then it will be removed from the pool.
            if (client) {
                done(client);
            }
            //res.writeHead(500, { 'content-type': 'text/plain' });
            //res.end('An error occurred');
            var result = {};
            result.error = "An error occurred";
            result.message = err.message;
            result.detail = err;
            res.json(result);
            return true;
        };
        
        // handle an error from the connection
        // INSERT INTO visit (date) VALUES ($1)
        if (handleError(err)) return;
        //var selectString = 'select a."Start_TS" s, a."End_TS" e, a."RollupDate" r from dailyrolluptimes a where a."Server" !=\'BER\' and a."End_TS" is not null and a."ElapseTime" > 0 order by a."RollupDate" desc limit 1;';
        var selectString = multiline.stripIndent(function () { 
            /*
            select a."Start_TS" s, a."End_TS" e, a."RollupDate" r 
            from dailyrolluptimes a 
            where a."Server" != $1 and a."End_TS" is not null and a."ElapseTime" > $2
            order by a."RollupDate" desc 
            limit 1;
            */
        });
        
        // record the visit
        client.query(selectString, ['BER', 0], function (err, result) {
            
            // handle an error from the query
            if (handleError(err)) return;
            
            // return the client to the connection pool for other requests to reuse
            done();
            
            //res.writeHead(200, { 'content-type': 'text/plain' });
            //res.end('You are visitor number ' + result.rows[0].count);
            var rst = {};
            rst.info = result.rows[0].r;
            res.json(rst);
        });
    });
});

router.get('/t2', function (req, res) {
    var conString = res.app.get('pgConnString');
    var handleError = res.app.get('pgErrorHandler');
    var templateHandler = res.app.get('getDataTemplate');
    
    var selectString = multiline.stripIndent(function () { 
            /*
            select a."Start_TS" s, a."End_TS" e, a."RollupDate" r 
            from dailyrolluptimes a 
            where a."Server" != $1 and a."End_TS" is not null and a."ElapseTime" > $2
            order by a."RollupDate" desc 
            limit 1;
            */
    });
    
    var sqlParams = ['BER', 0];
    
    var resultHandler = function (result) {
        var rst = {};
        rst.info = result.rows[0].r;
        res.json(rst);
    };
    
    templateHandler(pg, conString, handleError, selectString, sqlParams, resultHandler, res);
});

router.get('/t3', function (req, res) {
    var templateHandler = res.app.get('getDataTemplate2');
    
    var selectString = multiline.stripIndent(function () { 
            /*
            select a."Start_TS" s, a."End_TS" e, a."RollupDate" r 
            from dailyrolluptimes a 
            where a."Server" != $1 and a."End_TS" is not null and a."ElapseTime" > $2
            order by a."RollupDate" desc 
            limit 1;
            */
    });    
    var sqlParams = ['BER', 0];   
    var resultHandler = function (result) {
        var rst = {};
        rst.info = result.rows[0].r;
        res.json(result.rows);
    };    
    templateHandler(selectString, sqlParams, resultHandler, res);

});

module.exports = router;