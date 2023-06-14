const gulp = require('gulp');
const nodemon = require('gulp-nodemon');

gulp.task('start', function () {
    nodemon({
        script: 'server.js',
        ext: 'js html css',
        env: { 'NODE_ENV': 'development' }
    })
    .on('restart', function () {
        console.log('Server restarted!');
    });
});
