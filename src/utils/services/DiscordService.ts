enum Channel {
    GENERAL = '924174229686083595',
    CLIPS_AND_HIGHLIGHTS = '924174229686083596',
    CIV_6 = '1034542662516228147',
    ELDEN_RING = '1057074275661660300',
    HALO = '1034543058076831784',
    MINECRAFT = '1034545771548254238',
    TURTLE_FIRMWARE = '1194491880931594312',
    NORTHGARD = '1034549267714539590',
    SEA_OF_THIEVES = '1152686802642145462',
    STELLARIS = '1034545835100344461',
    VALHEIM = '1034542978192117840',
}

type DiscordMessageRequest = {
    channelID: Channel;
    message: String;
}

export default class DiscordService {
    constructor(token: string) {
        this.authenticate(token);
    }

    private authenticate(token: string) {
        // TODO: add authentication strategy with Discord API
        console.log(`token: ${token}`);
    }

    SendDiscordMessage(input: DiscordMessageRequest) {
        const { channelID, message } = input;
    
        // TODO: add logic to process DiscordMessageRequest
        console.log(`channel: ${channelID}`);
        console.log(`message: ${message}`);
    }
}
