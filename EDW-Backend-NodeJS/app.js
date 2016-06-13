var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
 
 require('./public/javascripts/utils.js');


var rollupanalytic = require('./routes/rollupanalytic.js');
var edwOptimization = require('./routes/edwoptimization.js');
var edwOptimizationLongRunning =  require('./routes/edwoptimizationlongrunning.js');
var rollupmecsummary = require('./routes/rollupmecsummary.js');
var rollupmecsummarydetail = require('./routes/rollupmecsummarydetail.js');
var slarollupinfo = require('./routes/slarollupinfo.js');
var mecdfs = require('./routes/mecdfs.js');
var mecdfsdetail = require('./routes/mecdfsdetail.js');
var mecdfsourcelist = require('./routes/mecdfsourcelist.js');  
var mcdfcmcdfctrend = require('./routes/mcdfcmcdfctrend.js'); 
var mcdfclinetrend = require('./routes/mcdfclinetrend.js');



var app = express();

app.all('*', function (req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Content-Length, Authorization, Accept, X-Requested-With , yourHeaderFeild');
    res.header('Access-Control-Allow-Methods', 'PUT, POST, GET, DELETE, OPTIONS');
    
    if (req.method == 'OPTIONS') {
        res.send(200); /让options请求快速返回/
    }
    else {
        next();
    }
});

// view engine setup
// app.set('views', path.join(__dirname, 'views'));
// app.set('view engine', 'jade');
// app.engine('html', require('ejs').renderFile);
//app.set('view engine', 'html');
app.set('pgConnString', 'postgres://postgres:123456@16.152.122.102/EDWData');

// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(require('stylus').middleware(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'public')));

app.use('/edwoptimization', edwOptimization);
app.use('/edwoptimizationlongrunning', edwOptimizationLongRunning);
app.use('/rollupmecsummary', rollupmecsummary);
app.use('/rollupmecsummarydetail', rollupmecsummarydetail);
app.use('/slarollupinfo', slarollupinfo);
app.use('/rollupanalytic', rollupanalytic);
app.use('/mecdfs', mecdfs);
app.use('/mecdfsdetail', mecdfsdetail);
app.use('/mecdfsourcelist', mecdfsourcelist);
app.use('/mcdfcmcdfctrend', mcdfcmcdfctrend);
app.use('/mcdfclinetrend', mcdfclinetrend);



// catch 404 and forward to error handler
app.use(function (req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function (err, req, res, next) {
               // Website you wish to allow to connect
        res.setHeader('Access-Control-Allow-Origin', "*");

        // Request methods you wish to allow
        res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');

        // Request headers you wish to allow
        res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

        // Set to true if you need the website to include cookies in the requests sent
        // to the API (e.g. in case you use sessions)
        res.setHeader('Access-Control-Allow-Credentials', true);
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
    
    app.set('json spaces', 2);
}

// production error handler
// no stacktraces leaked to user
app.use(function (err, req, res, next) {
       // Website you wish to allow to connect
    res.setHeader('Access-Control-Allow-Origin', "*");

    // Request methods you wish to allow
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');

    // Request headers you wish to allow
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

    // Set to true if you need the website to include cookies in the requests sent
    // to the API (e.g. in case you use sessions)
    res.setHeader('Access-Control-Allow-Credentials', true);

    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });    
    // Pass to next layer of middleware
    next();
});

app.set('pgErrorHandler', function (err, client, done, res) {
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
});

app.set('getDataTemplate2', function (selectSql, parameters, resultHandler, res) {
    var pg = require('pg');
    var connString = 'postgres://postgres:123456@16.152.122.102/EDWData';
    var pgErrorHandler = function (err, client, done) {
        if (!err) return false;
        if (client) {
            done(client);
        }
        var result = {};
        result.error = "An error occurred";
        result.message = err.message;
        result.detail = err;
        res.json(result);
        return true;
    }
    
    pg.connect(connString, function (err, client, done) {
        if (pgErrorHandler(err, client, done)) return;
        client.query(selectSql, parameters, function (err, result) {
            if (pgErrorHandler(err, client, done)) return;
            done();
            resultHandler(result);
        });
    });
});



module.exports = app;
