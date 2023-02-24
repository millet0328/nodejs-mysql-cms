// JSON Web Token
const jwt = require('jsonwebtoken');
const { expressjwt } = require('express-jwt');

class TokenManager {
    constructor({ private_key, public_key, access_expired_time, refresh_expired_time }, options) {
        this.secretOrPrivateKey = private_key;
        this.secretOrPublicKey = public_key;
        this.access_expired_time = access_expired_time;
        this.refresh_expired_time = refresh_expired_time;
        //algorithm + keyid + noTimestamp + expiresIn + notBefore
        this.options = options;
    }

    // 签发token
    sign(payload, signOptions) {
        const jwtSignOptions = { ...this.options, ...signOptions };
        return jwt.sign(payload, this.secretOrPrivateKey, jwtSignOptions);
    }

    // 校验token
    verify(payload, verifyOptions) {
        const jwtVerifyOptions = { ...this.options, ...verifyOptions };
        return jwt.verify(payload, this.secretOrPrivateKey, jwtVerifyOptions);
    }

    // 签发access_token
    create_access_token(payload, signOptions) {
        return this.sign(payload, { expiresIn: this.access_expired_time, ...signOptions })
    }

    // 签发refresh_token
    create_refresh_token(payload, signOptions) {
        return this.sign(payload, { expiresIn: this.refresh_expired_time, ...signOptions })
    }

    // token守卫，每一个路由都校验，白名单中路由无需校验。
    guard(path = [], isRevoked) {
        return expressjwt({ secret: this.secretOrPublicKey, algorithms: ['HS256'], isRevoked }).unless({ path });
    }
}

// PrivateKey
const PrivateKey = 'millet';
// PublicKey
const PublicKey = 'millet';
// access_token有效期
const Access_Expired_Time = '30m';
// refresh_token有效期
const Refresh_Expired_Time = '30d';

let token_manager = new TokenManager({
    private_key: PrivateKey,
    public_key: PublicKey,
    access_expired_time: Access_Expired_Time,
    refresh_expired_time: Refresh_Expired_Time,
});

module.exports = token_manager;
