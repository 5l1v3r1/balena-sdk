import * as BalenaSdk from '../typings/balena-sdk';
import { AnyObject } from '../typings/utils';

let anyObject: AnyObject;
let d: BalenaSdk.Device;
const deviceOpt = { resource: 'device' as const };

function f1<T extends string>(
	a: T,
): T extends keyof BalenaSdk.ResouceTypeMap
	? BalenaSdk.ResouceTypeMap[T]
	: AnyObject {
	return {} as any;
}
d = f1('device');
anyObject = f1('asdf');

function f2<T extends string>(a: {
	resource: T;
}): T extends keyof BalenaSdk.ResouceTypeMap
	? BalenaSdk.ResouceTypeMap[T]
	: AnyObject {
	return {} as any;
}
d = f2({ resource: 'device' });
anyObject = f2({ resource: 'asdf' });
d = f2(deviceOpt);

function f3<T extends { resource: string }>(
	a: T,
): T['resource'] extends keyof BalenaSdk.ResouceTypeMap
	? BalenaSdk.ResouceTypeMap[T['resource']]
	: AnyObject {
	return {} as any;
}
d = f3({ resource: 'device' }); // $ExpectError
anyObject = f3({ resource: 'asdf' });
d = f3(deviceOpt);

function f4<T extends { resource: string }>(
	a: T,
): T extends { resource: infer K }
	? K extends keyof BalenaSdk.ResouceTypeMap
		? BalenaSdk.ResouceTypeMap[K]
		: AnyObject
	: AnyObject {
	return {} as any;
}
d = f4({ resource: 'device' }); // $ExpectError
anyObject = f4({ resource: 'asdf' });
d = f4(deviceOpt);

function f5<T extends { resource: K }, K extends string = string>(
	a: T,
): T['resource'] extends keyof BalenaSdk.ResouceTypeMap
	? BalenaSdk.ResouceTypeMap[T['resource']]
	: AnyObject {
	return {} as any;
}
d = f5({ resource: 'device' });
anyObject = f5({ resource: 'asdf' });
d = f5(deviceOpt);

function f6<T extends { resource: K }, K extends string | {} = string>(
	a: T,
): T['resource'] extends keyof BalenaSdk.ResouceTypeMap
	? BalenaSdk.ResouceTypeMap[T['resource']]
	: AnyObject {
	return {} as any;
}
d = f6({ resource: 'device' });
anyObject = f6({ resource: 'asdf' });
d = f6(deviceOpt);
